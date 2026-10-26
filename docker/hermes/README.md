# Hermes

[Hermes Agent](https://github.com/NousResearch/hermes-agent) (WhatsApp gateway, API server on 8642,
dashboard on 9119) and [hermes-webui](https://github.com/nesquena/hermes-webui) on 8787.
Data: `/docker/hermes`, mounted at `/opt/data`. Coding tasks go to the `coder` stack
(`docker/coder`) through the `ship` skill.

## Profiles

`default` (owner) and `mom`, both on one gateway (`gateway.multiplex_profiles`), with WhatsApp chats
routed by `gateway.profile_routes`. Only the default profile may bind ports: a secondary profile
must set `platforms.webhook.enabled: false` and `platforms.api_server.enabled: false` in its
`config.yaml` (an env flag isn't enough), or the gateway skips it at startup. The unused
`dev`, `frontend`, `life` and `trader` profiles were removed on 2026-10-26; the tarball is in
`/docker/hermes/archive/`.

## Backups

- `hermes-home-sync.sh`, from adigen's crontab at 00:00 host time (before borgmatic):
  takes a `hermes backup -q` state snapshot into `/docker/hermes/state-snapshots/` (kept: 3), then
  copies the text state (soul, memories, skills, cron jobs, redacted config, memory-store facts) of
  the main home and each profile into `/docker/hermes-home` and pushes it to the private
  `mradigen/hermes-home` repo. Log: `~/.local/state/hermes-home-sync.log`.
- Push uses a write deploy key, `~/.ssh/hermes_home_deploy`, through the `github-hermes-home` host
  alias in `~/.ssh/config`.
- Everything else (`state.db`, sessions, WhatsApp session, `.env`) only goes off-site through
  borgmatic's copy of `/docker`.

Crontab line:
```
0 0 * * * /home/adigen/docker/hermes/hermes-home-sync.sh >> /home/adigen/.local/state/hermes-home-sync.log 2>&1
```

## Research repo

Hermes' `decide` skill writes reports to `/docker/hermes/research`, a clone of the private
`mradigen/research` repo. It pushes from inside the container with the deploy key at
`/docker/hermes/keys/research_deploy` (set as `core.sshCommand` in that clone).

## Secrets

`.env` here: `DATA_PATH`, `HERMES_WORKSPACE`, `DASH_USER`, `DASH_PASS`, `UID`, `GID`. Hermes' own
API keys live in `/docker/hermes/.env`. Not in Vault yet (see the commented entry in
`ansible/playbooks/docker-vyria.yml`).
