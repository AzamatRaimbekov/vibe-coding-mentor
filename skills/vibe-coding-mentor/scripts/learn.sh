#!/usr/bin/env bash
# Дописывает урок о СВОЕЙ ошибке в references/lessons.md.
#   learn.sh "Название" "Что случилось" "Почему ошибся" "Правило"
set -u
F="$HOME/.claude/skills/vibe-coding-mentor/references/lessons.md"
[ $# -eq 4 ] || { echo "Нужно 4 аргумента: название, что случилось, почему, правило"; exit 1; }
[ -f "$F" ] || { echo "Нет файла уроков: $F"; exit 1; }
grep -qiF "## $1" "$F" && { echo "⚠️ Урок «$1» уже есть — дополни его, а не дублируй"; exit 1; }
{ printf '\n## %s\n' "$1"
  printf '**Дата:** %s\n' "$(date +%Y-%m-%d)"
  printf '**Что случилось:** %s\n' "$2"
  printf '**Почему ошибся:** %s\n' "$3"
  printf '**Правило:** %s\n' "$4"; } >> "$F"
echo "🧠 Записал урок: $1"
echo "Всего уроков: $(grep -c '^\*\*Дата:\*\* 2' "$F")"
