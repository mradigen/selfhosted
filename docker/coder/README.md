# coder

Claude Code worker for Hermes. Idle container with Claude Code, git and gh; Hermes' `ship` skill
runs `docker exec -u node coder claude -p ...` in a per-task git worktree, and Claude opens a PR.

- Repos: `/docker/coder/repos` (`/repos`), worktrees in `/repos/.wt/`.
- Home (Claude sessions, so `--resume` works): `/docker/coder/home` (`/home/node`).
- Update Claude Code: `docker compose build --pull && docker compose up -d`.

## .env

```
DATA_PATH=/docker/coder
GIT_NAME=mradigen
GIT_EMAIL=55953083+mradigen@users.noreply.github.com
CLAUDE_CODE_OAUTH_TOKEN=   # `claude setup-token` (Claude subscription)
GH_TOKEN=                  # fine-grained PAT: Contents + Pull requests read/write on chosen repos
```
