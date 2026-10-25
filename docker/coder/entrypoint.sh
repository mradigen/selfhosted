#!/bin/sh
# Use the GH_TOKEN for git push/pull over https, then idle; work arrives via docker exec.
gh auth setup-git >/dev/null 2>&1 || true
exec sleep infinity
