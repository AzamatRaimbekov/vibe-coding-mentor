#!/usr/bin/env bash
# Сохраняет ключ доступа и сразу подключает службу.
# Человек делает ровно одно: приносит ключ. Всё остальное — здесь.
#   bash add-key.sh stitch   <КЛЮЧ>
#   bash add-key.sh supabase <ТОКЕН>
set -u

NAME="${1:-}"; KEY="${2:-}"
SECRETS="$HOME/.claude/.secrets"

case "$NAME" in
  stitch)   FILE="stitch-api-key" ;;
  supabase) FILE="supabase-token" ;;
  *) printf 'Не знаю службу «%s». Знаю: stitch, supabase\n' "$NAME"; exit 1 ;;
esac

if [ -z "$KEY" ]; then
  printf 'Нужен ключ вторым аргументом: bash add-key.sh %s <КЛЮЧ>\n' "$NAME"; exit 1
fi

mkdir -p "$SECRETS"; chmod 700 "$SECRETS"
printf '%s' "$KEY" > "$SECRETS/$FILE"
chmod 600 "$SECRETS/$FILE"

printf '🔑 Ключ сохранён в %s/%s — файл виден только тебе (права 600).\n' "$SECRETS" "$FILE"
printf '   В чат он больше не попадёт: скрипты читают его с диска.\n\n'

exec bash "$HOME/.claude/skills/mcp-setup/scripts/ensure-mcp.sh"
