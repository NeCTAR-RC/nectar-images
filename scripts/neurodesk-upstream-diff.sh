#!/bin/bash
# Show upstream Neurodesktop changes since our last sync.
#
# Our Neurodesktop image (ansible/roles/neurodesk) is manually translated
# from the upstream Dockerfile at https://github.com/neurodesk/neurodesktop.
# The upstream commit we last synced from is pinned in
# ansible/roles/neurodesk/UPSTREAM_REF.
#
# This script fetches upstream into a local cache and shows the commit log,
# diffstat and full diff between the pin and a target ref, restricted to the
# paths that matter to us (Dockerfile, config/, scripts/). The target
# defaults to the latest upstream GitHub release tag, falling back to main.
#
# Usage:
#   scripts/neurodesk-upstream-diff.sh [-l] [target-ref]
#
#   -l, --log-only   show only the commit log and diffstat, not the full diff
#   target-ref       upstream tag, branch or SHA to compare against
#
# After syncing the role, update UPSTREAM_REF to the target ref used here.

set -euo pipefail

REPO_DIR=$(cd "$(dirname "$0")/.." && pwd)
PIN_FILE=$REPO_DIR/ansible/roles/neurodesk/UPSTREAM_REF
UPSTREAM_URL=https://github.com/neurodesk/neurodesktop
UPSTREAM_API=https://api.github.com/repos/neurodesk/neurodesktop
CACHE_DIR=${NEURODESK_UPSTREAM_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/neurodesk-upstream}

# Paths relevant to our image; excludes container-only build machinery
PATHS=(Dockerfile config scripts)

log_only=0
target=

usage() {
    sed -n '2,20p' "$0" | sed 's/^# \?//'
    exit "${1:-0}"
}

while [ $# -gt 0 ]; do
    case $1 in
        -l|--log-only) log_only=1 ;;
        -h|--help) usage ;;
        -*) echo "Unknown option: $1" >&2; usage 1 >&2 ;;
        *) target=$1 ;;
    esac
    shift
done

pin=$(grep -Ev '^[[:space:]]*(#|$)' "$PIN_FILE" | head -1)
if [ -z "$pin" ]; then
    echo "No ref found in $PIN_FILE" >&2
    exit 1
fi

if [ -z "$target" ]; then
    target=$(curl -fsSL "$UPSTREAM_API/releases/latest" 2>/dev/null |
        grep -m1 '"tag_name"' | cut -d'"' -f4 || true)
    if [ -z "$target" ]; then
        echo "Could not determine latest upstream release, using main" >&2
        target=main
    fi
fi

# Blob-less bare clone: full history for log/diff, blobs fetched on demand
if [ ! -d "$CACHE_DIR" ]; then
    echo "Cloning $UPSTREAM_URL into $CACHE_DIR ..." >&2
    git clone --quiet --bare --filter=blob:none "$UPSTREAM_URL" "$CACHE_DIR"
else
    echo "Fetching $UPSTREAM_URL ..." >&2
    git -C "$CACHE_DIR" fetch --quiet origin \
        '+refs/heads/*:refs/heads/*' --tags --prune
fi

pin_commit=$(git -C "$CACHE_DIR" rev-parse --verify "$pin^{commit}")
target_commit=$(git -C "$CACHE_DIR" rev-parse --verify "$target^{commit}")

show_date() {
    git -C "$CACHE_DIR" show -s --format=%cs "$1"
}

echo
echo "Upstream Neurodesktop changes: ${pin:0:12} ($(show_date "$pin_commit"))" \
     "-> $target ($(show_date "$target_commit"))"
echo "Paths: ${PATHS[*]}"
echo

echo "=== Commits ==="
git -C "$CACHE_DIR" log --oneline --no-merges --reverse \
    "$pin_commit..$target_commit" -- "${PATHS[@]}"
echo

echo "=== Diffstat ==="
git -C "$CACHE_DIR" diff --stat "$pin_commit..$target_commit" -- "${PATHS[@]}"
echo

if [ "$log_only" -eq 0 ]; then
    echo "=== Diff ==="
    git -C "$CACHE_DIR" diff "$pin_commit..$target_commit" -- "${PATHS[@]}"
fi
