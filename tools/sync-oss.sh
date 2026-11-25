#!/usr/bin/env bash
# Copy files that exist in oss/ but not in this repo; drop copies that oss no longer has.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
manifest=.oss-synced
touch "$manifest"
oss=$(mktemp); mine=$(mktemp); new=$(mktemp); trap 'rm -f "$oss" "$mine" "$new"' EXIT

git -c core.quotepath=off -C oss ls-files | LC_ALL=C sort > "$oss"
git -c core.quotepath=off ls-files | LC_ALL=C sort > "$mine"
LC_ALL=C comm -23 "$oss" "$mine" > "$new"  # private file wins

[ -s "$new" ] && tar -C oss -cf - -T "$new" | tar -xf -
# remove files synced earlier that the pinned oss lacks and that are not tracked
LC_ALL=C comm -23 <(LC_ALL=C sort "$manifest") "$new" | LC_ALL=C comm -23 - "$mine" | while IFS= read -r f; do rm -f -- "$f"; done
cp "$new" "$manifest"

# keep synced files out of `git status`
exclude=$(git rev-parse --git-path info/exclude)
{ grep -vxF -f <(sed 's/^/\//' "$new") "$exclude" 2>/dev/null || true; sed 's/^/\//' "$new"; } > "$exclude.new" && mv "$exclude.new" "$exclude"
echo "sync-oss: $(wc -l < "$manifest" | tr -d ' ') files from oss $(git -C oss describe --tags --always)"
