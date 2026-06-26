#!/usr/bin/env python3
import hashlib
import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path

BASE00 = "1e1e2e"
BASE01 = "181825"
BLUE = "89b4fa"
GREEN = "a6e3a1"
YELLOW = "f9e2af"
MAUVE = "cba6f7"


def run(args, cwd=None, timeout=None, env=None):
    try:
        return subprocess.run(
            args,
            cwd=cwd,
            timeout=timeout,
            env=env,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
            check=False,
        )
    except (OSError, subprocess.TimeoutExpired):
        return None


def git(worktree, *args, timeout=None):
    return run(["git", "-C", str(worktree), *args], timeout=timeout)


def is_git_worktree(path):
    if not path:
        return False
    result = git(path, "rev-parse", "--is-inside-work-tree", timeout=1)
    return bool(result and result.returncode == 0)


def expand_title_path(title):
    if not title:
        return None
    title = title.strip()
    if title.startswith("~/") or title == "~":
        return str(Path(title).expanduser())
    if title.startswith("/"):
        return title
    return None


def active_session_metadata_path():
    session_name = os.environ.get("ZELLIJ_SESSION_NAME", "")
    session_info_dir = Path(
        os.environ.get(
            "ZELLIJ_STATUS_METADATA_DIR",
            str(Path.home() / "Library/Caches/org.Zellij-Contributors.Zellij/contract_version_1/session_info"),
        )
    )

    if session_name:
        metadata = session_info_dir / session_name / "session-metadata.kdl"
        if metadata.is_file():
            return metadata

    if not session_info_dir.is_dir():
        return None

    candidates = list(session_info_dir.glob("*/session-metadata.kdl"))
    if not candidates:
        return None
    return max(candidates, key=lambda p: p.stat().st_mtime)


def first_match(pattern, text):
    match = re.search(pattern, text, re.S)
    return match.group(1) if match else None


def active_tab_name(metadata_text):
    for match in re.finditer(r"tab \{(?P<body>.*?)\n    \}", metadata_text, re.S):
        body = match.group("body")
        if re.search(r"active true", body):
            return first_match(r'name "([^"]+)"', body)
    return None


def focused_pane_title(metadata_text):
    for match in re.finditer(r"pane \{(?P<body>.*?)\n    \}", metadata_text, re.S):
        body = match.group("body")
        if re.search(r"is_plugin false", body) and re.search(r"is_focused true", body):
            return first_match(r'title "([^"]+)"', body)
    return None


def gwh_path_for_branch(branch):
    if not branch or branch.startswith("Tab #"):
        return None
    result = run(["gwh", "ls", "--all", "--format", "json"], timeout=1)
    if not result or result.returncode != 0 or not result.stdout.strip():
        return None
    try:
        data = json.loads(result.stdout)
    except json.JSONDecodeError:
        return None
    for row in data.get("rows", []):
        if row.get("branch") == branch and row.get("path"):
            return row["path"]
    return None


def find_active_zellij_worktree():
    metadata = active_session_metadata_path()
    if not metadata:
        return None
    try:
        text = metadata.read_text()
    except OSError:
        return None

    title_path = expand_title_path(focused_pane_title(text))
    if title_path and is_git_worktree(title_path):
        return title_path

    gwh_path = gwh_path_for_branch(active_tab_name(text))
    if gwh_path and is_git_worktree(gwh_path):
        return gwh_path

    return None


def resolve_worktree(argv):
    if len(argv) > 1 and argv[1]:
        if is_git_worktree(argv[1]):
            return argv[1]
        return find_active_zellij_worktree()

    candidates = []
    if os.environ.get("PWD"):
        candidates.append(os.environ["PWD"])
    candidates.append(os.getcwd())

    for candidate in candidates:
        if is_git_worktree(candidate):
            return candidate

    return find_active_zellij_worktree()


def pill(color, icon, text):
    if not text:
        return ""
    return (
        f"#[bg=#{BASE00},fg=#{color}]"
        f"#[bg=#{color},fg=#{BASE01},bold] {icon} {text} "
        f"#[bg=#{BASE00},fg=#{color}]"
    )


def cache_key(repo, branch):
    return hashlib.sha1(f"{repo}:{branch}".encode()).hexdigest()


def cache_base():
    if os.environ.get("XDG_CACHE_HOME"):
        return Path(os.environ["XDG_CACHE_HOME"])
    return Path.home() / "Library/Caches"


def pr_label(repo, branch):
    if not shutil_which("gh"):
        return None

    cache_dir = cache_base() / "zellij-statusline"
    try:
        cache_dir.mkdir(parents=True, exist_ok=True)
    except OSError:
        return None

    cache_file = cache_dir / f"pr-{cache_key(repo, branch)}"
    try:
        age = time.time() - cache_file.stat().st_mtime
        if age < 300:
            cached = cache_file.read_text().strip()
            return None if cached == "__none__" else cached
    except OSError:
        pass

    template = "{{if .isDraft}}#{{.number}} draft{{else}}#{{.number}}{{end}}"
    result = run(
        ["gh", "pr", "view", "--json", "number,isDraft", "--template", template],
        cwd=repo,
        timeout=1,
    )
    label = result.stdout.strip() if result and result.returncode == 0 else ""

    try:
        cache_file.write_text(label if label else "__none__")
    except OSError:
        pass

    return label or None


def shutil_which(command):
    for path in os.environ.get("PATH", "").split(os.pathsep):
        candidate = Path(path) / command
        if candidate.is_file() and os.access(candidate, os.X_OK):
            return str(candidate)
    return None


def git_output(worktree, *args):
    result = git(worktree, *args, timeout=1)
    if not result or result.returncode != 0:
        return None
    return result.stdout.strip()


def status_counts(worktree):
    result = git(worktree, "status", "--porcelain=v1", "-b", timeout=2)
    staged = modified = untracked = ahead = behind = 0
    if not result or result.returncode != 0:
        return staged, modified, untracked, ahead, behind

    for line in result.stdout.splitlines():
        if line.startswith("## "):
            ahead_match = re.search(r"ahead\s+(\d+)", line)
            behind_match = re.search(r"behind\s+(\d+)", line)
            ahead = int(ahead_match.group(1)) if ahead_match else ahead
            behind = int(behind_match.group(1)) if behind_match else behind
            continue
        if not line:
            continue
        index = line[0]
        work = line[1] if len(line) > 1 else " "
        if index == "?" and work == "?":
            untracked += 1
        else:
            if index != " ":
                staged += 1
            if work != " ":
                modified += 1
    return staged, modified, untracked, ahead, behind


def main(argv):
    worktree = resolve_worktree(argv)
    if not worktree or not is_git_worktree(worktree):
        return 0

    repo_root = git_output(worktree, "rev-parse", "--show-toplevel")
    branch = git_output(worktree, "symbolic-ref", "--quiet", "--short", "HEAD")
    if not branch:
        branch = git_output(worktree, "rev-parse", "--short", "HEAD")
    if not repo_root or not branch:
        return 0

    segments = [
        pill(BLUE, "󰉋", Path(repo_root).name),
        pill(GREEN, "", branch),
    ]

    staged, modified, untracked, ahead, behind = status_counts(worktree)
    git_bits = []
    if staged:
        git_bits.append(f"+{staged}")
    if modified:
        git_bits.append(f"~{modified}")
    if untracked:
        git_bits.append(f"?{untracked}")
    if ahead:
        git_bits.append(f"⇡{ahead}")
    if behind:
        git_bits.append(f"⇣{behind}")
    if git_bits:
        segments.append(pill(YELLOW, "󰊢", " ".join(git_bits)))

    pr = pr_label(repo_root, branch)
    if pr:
        segments.append(pill(MAUVE, "", pr))

    print(" ".join(segment for segment in segments if segment))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
