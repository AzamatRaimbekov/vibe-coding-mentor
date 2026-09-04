#!/usr/bin/env bash
# Базовый набор вайбкодера: проверяет И СТАВИТ недостающее.
# По умолчанию — ставит. --check-only — только показать, ничего не трогая.
# Единый список скилов и плагинов живёт в скиле vibe-coding-mentor,
# чтобы два скила не расходились в том, что считать обязательным.
MENTOR="$HOME/.claude/skills/vibe-coding-mentor/scripts/ensure-tools.sh"
MODE=""; [ "${1:-}" = "--check-only" ] && MODE="--dry-run"

printf '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
if [ -n "$MODE" ]; then
  printf '🔌  ПРОВЕРЯЮ БАЗОВЫЙ НАБОР  ✨\n'
else
  printf '📦  ДОСТАВЛЯЮ БАЗОВЫЙ НАБОР  ✨\n'
fi
printf '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'

if [ -x "$MENTOR" ] || [ -f "$MENTOR" ]; then
  bash "$MENTOR" --with-stack $MODE
else
  printf 'FAILED|скил vibe-coding-mentor не установлен — ставлю\n'
  [ -z "$MODE" ] && npx -y skills add AzamatRaimbekov/vibe-coding-mentor -g -y >/dev/null 2>&1
  [ -f "$MENTOR" ] && bash "$MENTOR" --with-stack $MODE
fi

# ---------- MCP: доступ к внешнему миру ----------
have_mcp() { claude mcp list 2>/dev/null | grep -qi "^$1:"; }
if have_mcp playwright; then
  printf 'OK mcp playwright\n'
elif [ -n "$MODE" ]; then
  printf 'DRY mcp playwright\n'
else
  claude mcp add playwright -s user -- npx -y @playwright/mcp@latest >/dev/null 2>&1
  have_mcp playwright && printf '+ подключил playwright — умею открывать сайт и смотреть на него глазами\n' \
                      || printf '! playwright не подключился\n'
fi

# ---------- то, что может сделать только человек ----------
claude mcp list 2>/dev/null | grep -i 'needs authentication' | while read -r line; do
  printf 'ЧЕЛОВЕК авторизация %s\n' "${line%%:*}"
done
