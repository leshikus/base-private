#!/usr/bin/env bash
# Usage: tools/bump-oss.sh <oss-tag-or-ref>  -- pin oss to a version, sync files, commit the pin.
set -euo pipefail
ref=${1:?usage: bump-oss.sh <oss-tag-or-ref>}
cd "$(git rev-parse --show-toplevel)"
git -C oss fetch --tags -q
git -C oss checkout -q "$ref"
tools/sync-oss.sh
git add oss
git commit -q -m "Pin oss to $ref" && echo "pinned oss to $ref"
