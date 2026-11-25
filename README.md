# base-private

Private tree on top of the public `base-oss`, which is the submodule `oss/`.

1. **Pin.** The submodule commit is the version. `tools/bump-oss.sh v1.1.0` moves it and commits.
2. **Fill-in.** `tools/sync-oss.sh` copies each file of `oss/` that this repo does not track. A tracked file here wins.
3. **Hooks.** `.githooks/` runs the submodule update and the fill-in after checkout, merge and rebase. Run `tools/setup.sh` once per clone.
4. **Versions.** Keep one branch per line (`release/1.0` pinned to `v1.0.x`). Switching branches realigns `oss/` and the filled-in files.

`git submodule update` alone triggers no hook. Use `tools/bump-oss.sh`, or run `tools/sync-oss.sh` after it.
