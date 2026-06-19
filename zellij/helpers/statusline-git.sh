#!/usr/bin/env bash
set -euo pipefail

worktree=${1:-${PWD}}

if ! git -C "$worktree" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  exit 0
fi

if command -v gwh >/dev/null 2>&1; then
  if output=$(gwh statusline --format zjstatus --worktree "$worktree" 2>/dev/null) && [[ -n "$output" ]]; then
    printf '%s\n' "$output"
    exit 0
  fi
fi

if branch=$(git -C "$worktree" rev-parse --abbrev-ref HEAD 2>/dev/null) && [[ -n "$branch" ]]; then
  printf '#[fg=cyan] %s\n' "$branch"
fi
