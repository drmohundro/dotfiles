#!/usr/bin/env python3
"""Audit installed Homebrew packages: what they are, when they changed, and whether you use them."""

import argparse
import concurrent.futures
import json
import os
import re
import shutil
import sqlite3
import subprocess
import sys
import time
from pathlib import Path

HOME = Path.home()
ATUIN_DB = HOME / ".local/share/atuin/history.db"
FISH_HISTORY = HOME / ".local/share/fish/fish_history"
ZSH_HISTORY = HOME / ".zsh_history"
BASH_HISTORY = HOME / ".bash_history"

# Words that run another command, so the next word is the real command.
WRAPPERS = {"sudo", "env", "time", "command", "exec", "nohup", "nice", "xargs", "watch", "builtin", "doas", "caffeinate"}
SEGMENT_SPLIT = re.compile(r"\|\||&&|[|;&\n`]|\$\(|\(|\)|\bthen\b|\bdo\b|\belse\b|\band\b|\bor\b|\bnot\b")
ASSIGNMENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*=")
GITHUB = re.compile(r"github\.com[/:]([\w.-]+)/([\w.-]+?)(?:\.git)?(?:[/#?]|$)")


def run(*cmd):
    return subprocess.run(cmd, capture_output=True, text=True, check=True).stdout


def command_words(line):
    """Yield the command name of each pipeline/list segment in a shell line."""
    for segment in SEGMENT_SPLIT.split(line):
        for word in segment.split():
            if ASSIGNMENT.match(word) or word in WRAPPERS or word.startswith("-"):
                continue
            yield os.path.basename(word.strip("'\""))
            break


def history_entries():
    """Yield (command line, unix seconds or None), preferring atuin since it aggregates every shell."""
    if ATUIN_DB.exists():
        db = sqlite3.connect(f"file:{ATUIN_DB}?mode=ro", uri=True)
        for command, ts in db.execute("select command, timestamp from history where deleted_at is null"):
            yield command, ts // 1_000_000_000
        db.close()
        return

    if FISH_HISTORY.exists():
        cmd = None
        for line in FISH_HISTORY.read_text(errors="replace").splitlines():
            if line.startswith("- cmd: "):
                if cmd is not None:
                    yield cmd, None
                cmd = line[7:].replace("\\n", "\n")
            elif line.startswith("  when: ") and cmd is not None:
                yield cmd, int(line[8:])
                cmd = None
        if cmd is not None:
            yield cmd, None

    if ZSH_HISTORY.exists():
        for line in ZSH_HISTORY.read_bytes().decode(errors="replace").splitlines():
            m = re.match(r"^: (\d+):\d+;(.*)", line)
            yield (m.group(2), int(m.group(1))) if m else (line, None)

    if BASH_HISTORY.exists():
        ts = None
        for line in BASH_HISTORY.read_text(errors="replace").splitlines():
            if re.fullmatch(r"#\d{9,}", line):
                ts = int(line[1:])
            else:
                yield line, ts
                ts = None


def history_usage():
    """Map command name -> [count, last used]."""
    usage = {}
    for line, ts in history_entries():
        for word in set(command_words(line)):
            entry = usage.setdefault(word, [0, None])
            entry[0] += 1
            if ts and (entry[1] is None or ts > entry[1]):
                entry[1] = ts
    return usage


def config_words():
    """Words in tracked dotfiles, to spot tools invoked by config (pagers, prompts, shell init)."""
    repo = Path(__file__).resolve().parent.parent
    try:
        files = run("git", "-C", str(repo), "ls-files", "-z").split("\0")
    except (subprocess.CalledProcessError, FileNotFoundError):
        return set()
    words = set()
    for name in files:
        path = repo / name
        if name.endswith("lazy-lock.json") or not path.is_file() or path.stat().st_size > 1_000_000:
            continue
        try:
            words.update(re.findall(r"[\w.+-]{4,}", path.read_text()))
        except (UnicodeDecodeError, OSError):
            pass
    return words


def formula_commands(prefix, name):
    commands = set()
    for sub in ("bin", "sbin"):
        d = prefix / "opt" / name / sub
        if d.is_dir():
            commands.update(p.name for p in d.iterdir() if os.access(p, os.X_OK))
    return commands


def cask_artifacts(cask):
    commands, apps = set(), []
    for artifact in cask.get("artifacts", []):
        for entry in artifact.get("binary", []):
            if isinstance(entry, str):
                commands.add(os.path.basename(artifact.get("target") or entry))
        for entry in artifact.get("app", []):
            if isinstance(entry, str):
                apps.append(Path("/Applications") / entry)
    return commands, apps


def app_last_used(apps):
    """Spotlight's kMDItemLastUsedDate for each existing .app bundle."""
    existing = [str(a) for a in apps if a.exists()]
    if not existing or not shutil.which("mdls"):
        return {}
    out = subprocess.run(["mdls", "-raw", "-name", "kMDItemLastUsedDate", *existing], capture_output=True, text=True).stdout
    result = {}
    for path, value in zip(existing, out.split("\0")):
        try:
            result[path] = int(time.mktime(time.strptime(value.strip(), "%Y-%m-%d %H:%M:%S %z")))
        except ValueError:
            pass
    return result


def github_repo(*urls):
    for url in urls:
        m = url and GITHUB.search(url)
        if m:
            return f"{m.group(1)}/{m.group(2)}"
    return None


def github_info(repo):
    try:
        data = json.loads(run("gh", "api", f"repos/{repo}"))
        pushed = data.get("pushed_at")
        return {"pushed": int(time.mktime(time.strptime(pushed, "%Y-%m-%dT%H:%M:%SZ"))) - time.timezone if pushed else None,
                "archived": data.get("archived", False)}
    except (subprocess.CalledProcessError, json.JSONDecodeError):
        return None


def collect(args):
    data = json.loads(run("brew", "info", "--json=v2", "--installed"))
    prefix = Path(run("brew", "--prefix").strip())
    usage = history_usage()
    configured = config_words()

    dependents = {}
    for f in data["formulae"]:
        for dep in (f["installed"][0].get("runtime_dependencies") or []) if f["installed"] else []:
            dependents.setdefault(dep["full_name"].split("/")[-1], set()).add(f["name"])

    rows = []
    for f in data["formulae"]:
        installed = f["installed"][0] if f["installed"] else {}
        urls = f.get("urls", {})
        rows.append({
            "name": f["name"],
            "kind": "formula",
            "tap": f["tap"],
            "version": installed.get("version"),
            "requested": installed.get("installed_on_request", False),
            "dependents": sorted(dependents.get(f["name"], [])),
            "installed": installed.get("time"),
            "desc": f.get("desc") or "",
            "homepage": f.get("homepage"),
            "repo": github_repo(f.get("homepage"), (urls.get("head") or {}).get("url"), (urls.get("stable") or {}).get("url")),
            "commands": sorted(formula_commands(prefix, f["name"])),
            "apps": [],
        })

    all_apps = []
    for c in data["casks"]:
        commands, apps = cask_artifacts(c)
        all_apps += apps
        rows.append({
            "name": c["token"],
            "kind": "cask",
            "tap": c["tap"],
            "version": c.get("installed"),
            "requested": True,
            "dependents": [],
            "installed": c.get("installed_time"),
            "desc": c.get("desc") or "",
            "homepage": c.get("homepage"),
            "repo": github_repo(c.get("homepage"), c.get("url")),
            "commands": sorted(commands),
            "apps": [str(a) for a in apps],
        })

    app_used = app_last_used(all_apps)
    for row in rows:
        hits = [usage[c] for c in row["commands"] if c in usage]
        row["uses"] = sum(h[0] for h in hits)
        times = [h[1] for h in hits if h[1]] + [app_used[a] for a in row["apps"] if a in app_used]
        row["last_used"] = max(times) if times else None
        row["leaf"] = not row["dependents"]
        row["in_config"] = any(c in configured for c in row["commands"] if len(c) >= 4)

    if not args.all:
        rows = [r for r in rows if r["requested"]]
    if args.leaves:
        rows = [r for r in rows if r["leaf"]]
    if args.unused:
        rows = [r for r in rows if (r["commands"] or r["apps"]) and not r["last_used"] and not r["in_config"]]
    if args.kind:
        rows = [r for r in rows if r["kind"] == args.kind]

    if args.github:
        if not shutil.which("gh"):
            sys.exit("brew-usage: --github needs the gh CLI")
        with concurrent.futures.ThreadPoolExecutor(max_workers=16) as pool:
            for row, info in zip(rows, pool.map(lambda r: r["repo"] and github_info(r["repo"]), rows)):
                row["upstream_pushed"] = info and info["pushed"]
                row["archived"] = bool(info and info["archived"])

    return rows


def ago(ts, now=time.time()):
    if not ts:
        return "-"
    days = (now - ts) / 86400
    for unit, size in (("y", 365), ("mo", 30), ("w", 7), ("d", 1)):
        if days >= size:
            return f"{int(days // size)}{unit}"
    return "today"


SORTS = {
    "name": lambda r: r["name"],
    "used": lambda r: (r["last_used"] or 0, r["uses"]),
    "uses": lambda r: r["uses"],
    "installed": lambda r: r["installed"] or 0,
    "upstream": lambda r: r.get("upstream_pushed") or 0,
}


def print_table(rows, args):
    tty = sys.stdout.isatty() and not os.environ.get("NO_COLOR")
    dim, yellow, red, reset = ("\033[2m", "\033[33m", "\033[31m", "\033[0m") if tty else ("",) * 4

    columns = ["NAME", "KIND", "TAP", "DEPS", "INSTALLED", "LAST USED", "USES"]
    if args.github:
        columns.append("UPSTREAM")
    if args.wide:
        columns.append("REPO")
    columns.append("DESCRIPTION")

    table = []
    for r in rows:
        if not r["commands"] and not r["apps"]:
            last_used = "lib" if r["dependents"] else "-"
        else:
            last_used = ago(r["last_used"]) if r["last_used"] else "config" if r["in_config"] else "never"
        cells = [
            r["name"],
            "cask" if r["kind"] == "cask" else ("formula" if r["requested"] else "dep"),
            r["tap"].removeprefix("homebrew/"),
            str(len(r["dependents"])) if r["dependents"] else "",
            ago(r["installed"]),
            last_used,
            str(r["uses"]) if r["uses"] else "",
        ]
        if args.github:
            cells.append("archived" if r.get("archived") else ago(r.get("upstream_pushed")))
        if args.wide:
            repo = r["repo"] or (r["homepage"] or "").removeprefix("https://").removeprefix("http://")
            cells.append(repo if len(repo) <= 40 else repo[:39] + "…")
        cells.append(r["desc"])
        color = red if r.get("archived") else yellow if last_used == "never" and r["leaf"] else dim if not r["requested"] else ""
        table.append((cells, color))

    widths = [max([len(columns[i])] + [len(c[i]) for c, _ in table]) for i in range(len(columns) - 1)]
    desc_width = max(20, shutil.get_terminal_size((200, 20)).columns - sum(widths) - 2 * len(widths)) if tty else None

    def fmt(cells):
        desc = cells[-1]
        if desc_width and len(desc) > desc_width:
            desc = desc[: desc_width - 1] + "…"
        return "  ".join(c.ljust(w) for c, w in zip(cells, widths)) + "  " + desc

    print(fmt(columns))
    for cells, color in table:
        print(f"{color}{fmt(cells)}{reset if color else ''}")

    sys.stdout.flush()
    unused = sum(1 for r in rows if (r["commands"] or r["apps"]) and not r["last_used"] and not r["in_config"] and r["leaf"])
    print(f"\n{len(rows)} packages, {unused} leaf packages with no recorded use"
          f" (history: {'atuin' if ATUIN_DB.exists() else 'shell history files'})", file=sys.stderr)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("-a", "--all", action="store_true", help="include formulae installed only as dependencies")
    parser.add_argument("-l", "--leaves", action="store_true", help="only packages nothing else depends on")
    parser.add_argument("-u", "--unused", action="store_true", help="only packages with no recorded use")
    parser.add_argument("-k", "--kind", choices=["formula", "cask"], help="only formulae or only casks")
    parser.add_argument("-s", "--sort", choices=SORTS, default="used", help="sort column (default: used, least recent first)")
    parser.add_argument("-r", "--reverse", action="store_true", help="reverse the sort")
    parser.add_argument("-g", "--github", action="store_true", help="look up upstream last push / archived status via gh")
    parser.add_argument("-w", "--wide", action="store_true", help="add the repo/homepage column")
    parser.add_argument("--json", action="store_true", help="print JSON instead of a table")
    args = parser.parse_args()

    rows = sorted(collect(args), key=SORTS[args.sort], reverse=args.reverse)
    if args.json:
        json.dump(rows, sys.stdout, indent=2)
        print()
    else:
        print_table(rows, args)


if __name__ == "__main__":
    try:
        main()
    except (BrokenPipeError, KeyboardInterrupt):
        sys.exit(1)
