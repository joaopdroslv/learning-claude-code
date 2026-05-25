# ADD_DEV_CONTAINER

**ID:** ADR-005
**Timestamp:** 2026-05-25 13:30
**Status:** Accepted
**Type:** feature

## Context
Running Claude Code directly on the host gives it filesystem access well beyond the repo and unconstrained network egress — useful for casual work, dangerous for anything that touches secrets or could exfiltrate code. Anthropic explicitly recommends running Claude Code inside an isolated dev container for this reason, and publishes a reference implementation at [`anthropics/claude-code`'s `.devcontainer/`](https://github.com/anthropics/claude-code/tree/main/.devcontainer).

We want that same isolation here without losing the existing workflow: Python via pyenv (ADR-004), MySQL via `docker/docker-compose.dev.yml` (ADR-003), and the `mysql-dev` subagent driving `scripts/db-query.sh`.

## Decision
- **Vendor the Anthropic reference verbatim** into `.devcontainer/Dockerfile`, `.devcontainer/devcontainer.json`, and `.devcontainer/init-firewall.sh`. The firewall keeps the same default-deny posture (only GitHub, npm, Anthropic API, sentry, statsig, VS Code services are reachable; everything else is REJECTed via iptables).
- **Three project-specific deviations**, all called out in comments at the top of the relevant file:
  1. **Python toolchain inside the container.** The Dockerfile installs pyenv and pre-builds Python 3.13.3 (the version pinned in `.python-version`). This means `scripts/bootstrap/setup-venv.sh` works identically inside the container — same `pyenv exec python -m venv` invocation as on the host.
  2. **MySQL networking.** Rather than running the dev container in isolation, we layer `.devcontainer/docker-compose.yml` on top of the existing `docker/docker-compose.dev.yml` via `devcontainer.json`'s `dockerComposeFile` array. Both services live in the same compose project (`name: learning-claude-code`), so the dev container reaches MySQL by hostname `mysql` over the default docker network — no docker-socket mount needed. `init-firewall.sh` permits this because the same-subnet `HOST_NETWORK` rule covers the docker network the services share.
  3. **`scripts/db-query.sh` branches on `DEVCONTAINER`.** On the host it keeps using `docker compose exec`; inside the container it shells out to the `mysql` client directly against the `mysql` service host. The Dockerfile installs `default-mysql-client` to make that work.
- **PyPI is added to the firewall allowlist** (`pypi.org`, `files.pythonhosted.org`, `www.python.org`) so `pip install -r requirements.txt` works under the locked-down policy.
- **`.venv` is overlaid by a named volume** (`venv-data`) inside the container, so a Linux venv built inside doesn't collide with a Windows venv the host may have created at the same bind-mount path.
- **`Claude` config (`/home/node/.claude`) and bash history are named volumes** scoped to the dev container — they persist across rebuilds but never leak to the host. (The reference uses `${devcontainerId}`-keyed volumes; we use plain named volumes because the dev container is single-instance for this repo.)

## Alternatives considered
- **Skip dev container, rely on host alone.** Status quo. Fast but no isolation — Claude Code can read anything in `%USERPROFILE%`, and outbound network is wide open. Rejected for security.
- **Mount the docker socket so `db-query.sh` works unchanged inside the container.** Less code churn but punches a hole in the isolation (any process inside the container can spawn arbitrary containers on the host). Branching the script is cheaper.
- **Single combined `docker-compose.dev.yml` with both `mysql` and `devcontainer`.** Tighter coupling, but then `docker compose up` from the host CLI would always build/start the heavy dev container too. Two files lets each context bring up only what it needs.
- **Use `python:3.13-bookworm` as the base image and install Node on top.** Removes the pyenv build step (~3–5 min the first time the image is built). Rejected because matching the reference base (`node:20`) keeps us close to upstream — security fixes flow in by bumping the tag — and the pyenv layer is cached after the first build anyway.
- **Drop pyenv inside the container and rely on whatever Python the image ships.** Simpler Dockerfile, but the bootstrap script (`pyenv exec python -m venv`) would fail. Two divergent setup paths (host vs. container) is worse than one slow build.

## Consequences
**Positive:**
- Claude Code runs against a sandboxed filesystem (only `/workspace` bind-mounted) and a default-deny network. Egress is restricted to the allowlist; an accidental `curl evil.example.com` from inside the container fails.
- Same workflow on host and in the container: same `setup-venv.sh`, same `db-query.sh`, same `.python-version`, same MySQL credentials sourced from the same `.env`.
- "Open in container" from VS Code (or Cursor) is one click; the firewall and Python toolchain come up automatically via `postStartCommand` and the prebuilt image layer.

**Negative:**
- First-time image build is slow — pyenv compiles CPython 3.13.3 from source, which adds ~3–5 minutes on top of the reference build time. Subsequent builds use the cached layer.
- The dev container holds its own `.venv` and `~/.claude` config separate from the host. First login means re-authenticating `claude` inside the container; first venv use means re-running `./scripts/bootstrap/setup-venv.sh` inside the container.
- The allowlist will need maintenance. If we later pull packages from a private registry (Bevi's internal PyPI mirror, a private npm registry, etc.), the firewall script must be updated or the install will fail with a confusing connection-refused.
- The base image is Node-centric (`node:20`) — if upstream Anthropic switches base images, we need to track it. Adopting the reference verbatim makes that tracking easier, but it's still a maintenance dependency.
