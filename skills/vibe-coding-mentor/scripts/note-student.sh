#!/usr/bin/env bash
# Дописывает наблюдение об УЧЕНИКЕ в его профиль.
#   note-student.sh <раздел> "наблюдение"
# Разделы: знает | трудно | стиль | цели | решения
set -u
F="$HOME/.claude/skills/vibe-coding-mentor/references/student-profile.md"
[ $# -eq 2 ] || { echo "Нужно: note-student.sh <знает|трудно|стиль|цели|решения> \"наблюдение\""; exit 1; }
case "$1" in
  знает)   H="## Что уже уверенно знает" ;;
  трудно)  H="## Что даётся тяжело" ;;
  стиль)   H="## Как ему удобно работать" ;;
  цели)    H="## Куда движется" ;;
  решения) H="## Принятые решения" ;;
  *) echo "Неизвестный раздел: $1"; exit 1 ;;
esac
[ -f "$F" ] || { echo "Нет профиля: $F"; exit 1; }
grep -qF "$H" "$F" || { echo "Нет раздела $H"; exit 1; }
grep -qiF "$2" "$F" && { echo "⚠️ Такое наблюдение уже записано"; exit 1; }
python3 - "$F" "$H" "$2" "$(date +%Y-%m-%d)" <<'PY'
import sys
f, h, note, d = sys.argv[1:5]
s = open(f, encoding='utf-8').read()
i = s.index(h) + len(h)
j = s.find('\n## ', i)
j = len(s) if j == -1 else j
block = s[i:j].rstrip('\n')
open(f, 'w', encoding='utf-8').write(s[:i] + block + f"\n- {note}  _({d})_\n" + s[j:])
PY
echo "🧠 Запомнил про ученика [$1]: $2"
