#!/usr/bin/env bash
# Nightly Hermes backup. Runs on the host from cron, before borgmatic (05:00).
#   1. Takes a consistent Hermes state snapshot (state.db, .env, auth, cron) inside DATA_PATH,
#      so borgmatic carries a clean copy off-site along with the rest of /docker.
#   2. Copies Hermes' text "brain" (soul, memories, skills, cron jobs, config) for the main
#      home and every profile into the hermes-home git checkout, and pushes it.
# Secrets never go to git: config.yaml secret keys are redacted, and any value from a .env
# secret key or auth.json, or anything shaped like a known token, is replaced with <redacted>.
set -euo pipefail

SRC=${HERMES_DATA:-/docker/hermes}
REPO=${HERMES_HOME_REPO:-/docker/hermes-home}
KEEP_SNAPSHOTS=3 # ~300 MB each; borgmatic keeps the long history

docker exec hermes hermes backup -q -l nightly >/dev/null
ls -1d "$SRC"/state-snapshots/*-nightly 2>/dev/null | sort | head -n -"$KEEP_SNAPSHOTS" | xargs -r rm -rf

RSYNC=(rsync -a --delete --prune-empty-dirs
  --exclude '*.lock' --exclude '__pycache__/' --exclude 'node_modules/'
  --exclude '.hub/' --exclude '.curator_backups/' --exclude '.usage.json*')

# copy_home <hermes home dir> <destination in repo>
copy_home() {
  local home=$1 dest=$2
  mkdir -p "$dest"
  for f in SOUL.md profile.yaml; do
    if [ -f "$home/$f" ]; then cp "$home/$f" "$dest/$f"; else rm -f "$dest/$f"; fi
  done
  for d in memories skills hooks plugins knowledge plans reports; do
    if [ -d "$home/$d" ]; then "${RSYNC[@]}" "$home/$d/" "$dest/$d/"; else rm -rf "${dest:?}/$d"; fi
  done
  if [ -f "$home/cron/jobs.json" ]; then
    mkdir -p "$dest/cron" && cp "$home/cron/jobs.json" "$dest/cron/jobs.json"
  fi
  if [ -d "$home/scripts" ]; then
    "${RSYNC[@]}" --exclude 'whatsapp-bridge/' --exclude 'state/' \
      --include '*/' --include '*.sh' --include '*.py' --exclude '*' "$home/scripts/" "$dest/scripts/"
  fi
  if [ -f "$home/config.yaml" ]; then
    python3 - "$home/config.yaml" "$dest/config.yaml" <<'PY'
import re, sys
secret = re.compile(r'^(\s*-?\s*[\w.-]*(?:key|token|secret|password|passwd|credential)[\w.-]*\s*:\s*)(?!\$\{)(\S.*)$', re.I)
with open(sys.argv[1]) as src, open(sys.argv[2], 'w') as dst:
    for line in src:
        m = secret.match(line.rstrip('\n'))
        value = m.group(2).strip() if m else ''
        if m and value not in ('""', "''", 'null', '~', 'true', 'false', '[]', '{}') \
                and not re.fullmatch(r'-?[\d.]+', value):
            line = m.group(1) + '<redacted>\n'
        dst.write(line)
PY
  fi
  # The memory-store plugin keeps facts in sqlite; export them as sorted text for readable diffs.
  if [ -f "$home/memory_store.db" ]; then
    python3 - "$home/memory_store.db" "$dest/memory_store" <<'PY'
import json, os, sqlite3, sys
db = sqlite3.connect(f'file:{sys.argv[1]}?mode=ro', uri=True)
db.row_factory = sqlite3.Row
os.makedirs(sys.argv[2], exist_ok=True)
queries = {
    'facts': 'SELECT fact_id, content, category, tags, trust_score, created_at, updated_at FROM facts ORDER BY fact_id',
    'entities': 'SELECT entity_id, name, entity_type, aliases, created_at FROM entities ORDER BY entity_id',
    'fact_entities': 'SELECT * FROM fact_entities ORDER BY 1, 2',
}
for name, sql in queries.items():
    with open(os.path.join(sys.argv[2], f'{name}.jsonl'), 'w') as out:
        for row in db.execute(sql):
            out.write(json.dumps(dict(row), ensure_ascii=False) + '\n')
PY
  fi
}

copy_home "$SRC" "$REPO/home"
for profile in "$SRC"/profiles/*/; do
  [ -d "$profile" ] || continue
  name=$(basename "$profile")
  copy_home "$profile" "$REPO/profiles/$name"
done
for old in "$REPO"/profiles/*/; do
  [ -d "$old" ] && [ ! -d "$SRC/profiles/$(basename "$old")" ] && rm -rf "$old"
done

python3 - "$SRC" "$REPO" <<'PY'
import glob, json, os, re, sys
src, repo = sys.argv[1], sys.argv[2]
secret_name = re.compile(r'KEY|TOKEN|SECRET|PASS|AUTH|PRIVATE|CREDENTIAL|COOKIE', re.I)
values = set()
for env in glob.glob(f'{src}/.env') + glob.glob(f'{src}/profiles/*/.env'):
    for line in open(env, errors='ignore'):
        if '=' in line and not line.lstrip().startswith('#'):
            k, v = line.split('=', 1)
            v = v.strip().strip('"\'')
            if secret_name.search(k) and len(v) >= 12:
                values.add(v)
def token_like(s):
    # auth.json also holds env var names, URLs and timestamps; real tokens are long, unspaced, alphanumeric mixes.
    return (len(s) >= 20 and ' ' not in s and not s.startswith('http')
            and re.search(r'\d', s) and re.search(r'[a-zA-Z]', s) and not re.fullmatch(r'[\dT:.+Z-]+', s))
def strings(x):
    if isinstance(x, str): yield x
    elif isinstance(x, dict):
        for v in x.values(): yield from strings(v)
    elif isinstance(x, list):
        for v in x: yield from strings(v)
for auth in glob.glob(f'{src}/auth.json') + glob.glob(f'{src}/profiles/*/auth.json'):
    try:
        values.update(s for s in strings(json.load(open(auth))) if token_like(s))
    except Exception:
        pass
# Well-known token shapes, for secrets that aren't in any .env (e.g. pasted into chat and memorised).
token_pattern = re.compile(
    r'(Bearer\s+)[A-Za-z0-9._~+/=-]{16,}'
    r'|()\b(?:laya-[A-Za-z0-9_-]{16,}|sk-[A-Za-z0-9_-]{16,}|gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}'
    r'|AIza[0-9A-Za-z_-]{30,}|xox[abprs]-[A-Za-z0-9-]{10,}|eyJ[A-Za-z0-9_-]{15,}\.[A-Za-z0-9_-]{15,}\.[A-Za-z0-9_-]+)')
# Secrets pasted into chat end up in memories and facts; blank them in the git copy only.
for root, dirs, files in os.walk(repo):
    dirs[:] = [d for d in dirs if d != '.git']
    for f in files:
        path = os.path.join(root, f)
        try:
            text = open(path, encoding='utf-8').read()
        except UnicodeDecodeError:
            continue
        hits = [v for v in values if v in text]
        for v in hits:
            text = text.replace(v, '<redacted>')
        text, n = token_pattern.subn(lambda m: (m.group(1) or '') + '<redacted>', text)
        if hits or n:
            open(path, 'w', encoding='utf-8').write(text)
            print(f'redacted {len(hits) + n} secret value(s) in {os.path.relpath(path, repo)}')
PY

cd "$REPO"
git add -A
if ! git diff --cached --quiet; then
  git commit -q -m "sync: $(date +%F)"
fi
git push -q origin HEAD
