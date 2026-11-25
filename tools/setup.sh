#!/usr/bin/env bash
# One-time per clone: enable versioned hooks and recursive submodule handling.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
git config core.hooksPath .githooks
git config submodule.recurse true
git submodule update --init
tools/sync-oss.sh
