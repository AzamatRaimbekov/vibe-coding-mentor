#!/usr/bin/env bash
# Старт сессии: САМ доставляет недостающие скилы и плагины.
# Установка уходит в фон — старт сессии не ждёт сеть.
SK="$HOME/.claude/skills/vibe-coding-mentor"
[ -d "$SK" ] || exit 0

# 1. доставка в фоне, не чаще раза в сутки
nohup bash "$SK/scripts/ensure-tools.sh" --once --quiet --with-stack >/dev/null 2>&1 &
disown 2>/dev/null
# 1b. самообновление скила с GitHub — тоже в фоне, не чаще раза в сутки
nohup bash "$SK/scripts/self-update.sh" >/dev/null 2>&1 &
disown 2>/dev/null

# 2. в контекст — только то, что реально изменилось в прошлый запуск
REPORT="$SK/.state/last-report.txt"; UPD="$SK/.state/update-report.txt"
CHANGED=$(cat "$REPORT" "$UPD" 2>/dev/null | grep -E '^(\+|!|\?|RESTART)')
[ -z "$CHANGED" ] && exit 0

printf '<vibecoding-tools priority="must-follow">\n'
printf 'Доставка инструментов отработала САМА. Прежде чем отвечать на задачу, объяви результат:\n'
printf '  «+» -> баннер: Я УСТАНОВИЛ <имя> (или Я ОБНОВИЛ, если строка про версию) и одна строка, что это даёт\n'
printf '  «!» -> скажи, что не встало и чем это грозит; повтори установку руками\n'
printf '  «?» -> находка с малым числом установок: спроси человека, ставить ли\n'
printf '  RESTART -> последним блоком попроси набрать /clear\n'
printf 'Повторно ничего не ставь — это уже сделано.\n\n'
printf '%s\n' "$CHANGED"
printf '</vibecoding-tools>\n'
