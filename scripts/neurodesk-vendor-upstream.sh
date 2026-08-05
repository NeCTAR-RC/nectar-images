#!/bin/bash
# Vendor upstream Neurodesktop config files into the neurodesk role.
#
# Copies the upstream files listed in
# ansible/roles/neurodesk/files/upstream/MANIFEST, at the commit pinned in
# ansible/roles/neurodesk/UPSTREAM_REF, into
# ansible/roles/neurodesk/files/upstream/. Files under that directory are
# byte-for-byte upstream and must not be edited by hand; locally modified
# copies belong in ansible/roles/neurodesk/files/config/ instead.
#
# Typical sync workflow:
#   1. scripts/neurodesk-upstream-diff.sh -l   # review upstream changes
#   2. update ansible/roles/neurodesk/UPSTREAM_REF to the new ref
#   3. scripts/neurodesk-vendor-upstream.sh    # re-vendor at the new pin
#   4. review 'git diff' and translate Dockerfile changes into the role
#
# Usage:
#   scripts/neurodesk-vendor-upstream.sh

set -euo pipefail

REPO_DIR=$(cd "$(dirname "$0")/.." && pwd)
ROLE_DIR=$REPO_DIR/ansible/roles/neurodesk
PIN_FILE=$ROLE_DIR/UPSTREAM_REF
VENDOR_DIR=$ROLE_DIR/files/upstream
MANIFEST=$VENDOR_DIR/MANIFEST
UPSTREAM_URL=https://github.com/neurodesk/neurodesktop
CACHE_DIR=${NEURODESK_UPSTREAM_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/neurodesk-upstream}

pin=$(grep -Ev '^[[:space:]]*(#|$)' "$PIN_FILE" | head -1)
if [ -z "$pin" ]; then
    echo "No ref found in $PIN_FILE" >&2
    exit 1
fi

# Blob-less bare clone: full history, blobs fetched on demand
if [ ! -d "$CACHE_DIR" ]; then
    echo "Cloning $UPSTREAM_URL into $CACHE_DIR ..." >&2
    git clone --quiet --bare --filter=blob:none "$UPSTREAM_URL" "$CACHE_DIR"
fi
if ! git -C "$CACHE_DIR" rev-parse --verify --quiet "$pin^{commit}" >/dev/null; then
    echo "Fetching $UPSTREAM_URL ..." >&2
    git -C "$CACHE_DIR" fetch --quiet origin \
        '+refs/heads/*:refs/heads/*' --tags --prune
fi
pin_commit=$(git -C "$CACHE_DIR" rev-parse --verify "$pin^{commit}")

# Remove previously vendored files first so upstream deletions propagate
find "$VENDOR_DIR" -type f ! -name MANIFEST ! -name README.md -delete
find "$VENDOR_DIR" -mindepth 1 -type d -empty -delete

while IFS= read -r path; do
    case $path in ''|\#*) continue ;; esac
    dest=$VENDOR_DIR/$path
    mkdir -p "$(dirname "$dest")"
    if ! git -C "$CACHE_DIR" show "$pin_commit:$path" > "$dest"; then
        echo "No such file upstream at ${pin_commit:0:12}: $path" >&2
        echo "Remove it from the MANIFEST or handle it in the role." >&2
        exit 1
    fi
    echo "vendored: $path"
done < "$MANIFEST"

echo
echo "Vendored MANIFEST files from $UPSTREAM_URL at ${pin_commit:0:12}"
echo "Review changes with: git diff -- ${VENDOR_DIR#"$REPO_DIR"/}"
