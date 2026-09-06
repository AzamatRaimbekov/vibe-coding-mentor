#!/usr/bin/env bash
# Включает Ralph в проекте: копирует цикл + правила с агентами ecc в <проект>/scripts/ralph/
# Использование: bash ~/.claude/skills/vibe-coding-mentor/scripts/ralph-init.sh [путь к проекту]
set -e
PROJECT="${1:-.}"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/../ralph" && pwd)"
DST="$PROJECT/scripts/ralph"
command -v jq >/dev/null || { echo "НЕТ jq — ставлю: brew install jq"; brew install jq >/dev/null 2>&1 || { echo "FAILED jq"; exit 1; }; }
[ -d "$PROJECT/.git" ] || { echo "FAILED: $PROJECT не git-репозиторий — Ralph сохраняет каждую задачу коммитом"; exit 1; }
mkdir -p "$DST"
for f in ralph.sh CLAUDE.md prd.json.example; do
  [ -f "$DST/$f" ] && { echo "OK $DST/$f"; continue; }
  cp "$SRC/$f" "$DST/$f"; echo "INSTALLED $DST/$f"
done
chmod +x "$DST/ralph.sh"
grep -q "scripts/ralph/progress.txt" "$PROJECT/.gitignore" 2>/dev/null || printf 'scripts/ralph/progress.txt\nscripts/ralph/.last-branch\nscripts/ralph/archive/\n' >> "$PROJECT/.gitignore"
echo "READY: напиши /prd → /ralph → в отдельном терминале: ./scripts/ralph/ralph.sh --tool claude 10"
