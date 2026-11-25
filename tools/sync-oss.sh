#!/usr/bin/env bash
# Copy files that exist in oss/ but not in this repo; drop copies that oss no longer has.
set -euo pipefail
root=$(git rev-parse --show-toplevel); cd "$root"
manifest=.oss-synced
touch "$manifest"
new=$(mktemp); trap 'rm -f "$new"' EXIT

git -C oss ls-files | while IFS= read -r f; do
    if git ls-files --error-unmatch -- "$f" >/dev/null 2>&1; then continue; fi  # private file wins
    mkdir -p "$(dirname "$f")"; cp "oss/$f" "$f"; echo "$f" >> "$new"
done
sort -o "$new" "$new"

# remove files synced earlier that the pinned oss version lacks
comm -23 <(sort "$manifest") "$new" | while IFS= read -r f; do rm -f -- "$f"; done
cp "$new" "$manifest"
echo "sync-oss: $(wc -l < "$manifest" | tr -d ' ') files from oss $(git -C oss describe --tags --always)"
# keep synced files out of `git status`
exclude=$(git rev-parse --git-path info/exclude)
{ grep -vxF -f <(sed 's/^/\//' "$manifest") "$exclude" 2>/dev/null || true; sed 's/^/\//' "$manifest"; } > "$exclude.new" && mv "$exclude.new" "$exclude"
