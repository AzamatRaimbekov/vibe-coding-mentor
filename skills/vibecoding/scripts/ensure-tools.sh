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
# Список служб и правила разговора живут в скиле mcp-setup — здесь только вызов.
MCP="$HOME/.claude/skills/mcp-setup/scripts/ensure-mcp.sh"
if [ -f "$MCP" ]; then
  bash "$MCP" ${MODE:+--check-only}
else
  printf '! скил mcp-setup не установлен — доступы не проверены\n'
fi
