# FIX_NAMED_VOLUME_OWNERSHIP

**ID:** ADR-008
**Timestamp:** 2026-05-25 16:15
**Status:** Accepted
**Type:** fix

## Context
The devcontainer (ADR-005) runs as the non-root user `node` (uid 1000), per Anthropic's reference and the principle of least privilege. The `docker-compose.yml` overlays a Docker **named volume** (`venv-data`) on `/workspace/.venv` so a Linux venv inside the container never collides with a Windows venv created at the same path on the host (ADR-004 + ADR-005).

The issue: Docker creates named volumes owned by `root:root`, regardless of the image's `USER` directive. When the container comes up, `/workspace/.venv` is owned by root with `0755` and the `node` user cannot write into it. Running `scripts/bootstrap/setup-venv.sh` fails with `Permission denied: '/workspace/.venv/include'` while `python -m venv` tries to populate the directory.

A second, smaller bug surfaced at the same time: the script's existence check `if [[ ! -d "$VENV" ]]` skipped venv creation when `.venv` *existed but was empty* — exactly the state a freshly-mounted named volume is in.

Constraints we need to honor:
- `remoteUser` must remain `node`. Switching to `root` would pollute file ownership on the host bind mount and violates the Anthropic reference's sandbox model.
- The fix must be idempotent: `postStartCommand` fires on every container start, not only on rebuild.
- It must not require the user to run anything from the host (e.g. `docker exec -u 0 …`) on every rebuild.

## Decision
Two changes.

**1. Pre-flight ownership reset, as root, via NOPASSWD sudo.** A new script `.devcontainer/init-volumes.sh` is installed at `/usr/local/bin/init-volumes.sh` and granted NOPASSWD sudo for `node` in `/etc/sudoers.d/node-init` (which now also covers `init-firewall.sh`). It walks a small list of volume mount points and `chown -R node:node`s each one — but only if the root of the path is not already owned by `node`, so the recursive walk is skipped on subsequent starts. `postStartCommand` is updated to:

```
sudo /usr/local/bin/init-volumes.sh && sudo /usr/local/bin/init-firewall.sh
```

`waitFor: postStartCommand` already gates VS Code / Claude on this chain, so the user-level `setup-venv.sh` never races the ownership fix.

**2. Empty-directory handling in `setup-venv.sh`.** The check that gates `python -m venv` now also fires when the directory exists but is empty:

```
if [[ ! -d "$VENV" || -z "$(ls -A "$VENV" 2>/dev/null)" ]]; then
  pyenv exec python -m venv "$VENV"
fi
```

This makes the bootstrap script correct against the "mounted-but-empty named volume" state, independent of the chown fix.

## Alternatives considered
- **Switch `remoteUser` to `root`**: trivially makes the symptom disappear, but (a) the host bind mount `/workspace` ends up with root-owned files (painful on Linux hosts), (b) anything Claude runs gains root, defeating the sandbox motivation behind ADR-005, and (c) it directly contradicts the Anthropic reference the devcontainer is based on. Rejected.
- **Add `chown` inline to `init-firewall.sh`**: one fewer file, but pollutes a script that the file header explicitly says is mirrored from upstream. Future syncs from the Anthropic reference would create a merge conflict for a concern unrelated to the firewall. Rejected for separation-of-concerns.
- **Document a manual `docker exec -u 0 <container> chown …` step in the README**: cheap, but the user has to remember it on every rebuild, and Claude itself can't run it (no host access). Rejected — the whole point of `postStartCommand` is automating exactly this kind of bootstrap.
- **Custom Docker volume driver / `uid`/`gid` mount options**: works for `tmpfs` and some plugins, but the default `local` driver of Docker named volumes does not honor uid/gid options. Would require a plugin or compose changes well outside the scope of this fix. Rejected.

## Consequences
**Positive:**
- `scripts/bootstrap/setup-venv.sh` now works end-to-end on a freshly rebuilt devcontainer with zero manual steps — first start, every start.
- Future named volumes (e.g. cache directories) can be added by appending one line to `VOLUMES=(...)` in `init-volumes.sh`; no further sudoers or devcontainer changes.
- `init-firewall.sh` stays a verbatim mirror of the Anthropic upstream (modulo the PyPI allowlist deviation already documented in ADR-005), so future upstream syncs are cleaner.
- The empty-dir fix in `setup-venv.sh` makes the script correct on the host too, not just inside the container — any case where `.venv/` exists but is empty is now handled.

**Negative:**
- One more script to keep in sync with reality: when a new named volume is added to `docker-compose.yml`, `init-volumes.sh`'s `VOLUMES` array must be updated. Easy to forget; the failure mode (permission denied at first use) is loud but not immediate.
- The `chown` runs as root with broad authority over any path listed in `VOLUMES`. A buggy entry (e.g. `/`) would be catastrophic. Mitigation: the array is short, code-reviewed, and the script is small enough to audit at a glance.
- Applying this fix to an *existing* devcontainer requires a rebuild (so the new script lands in `/usr/local/bin/` and the sudoers entry exists). Users on the current container still need the one-shot manual chown from the host.
