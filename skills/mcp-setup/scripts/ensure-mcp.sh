#!/usr/bin/env bash
# Подключает MCP-серверы САМ. Что нельзя без человека — печатает ссылкой.
# Флаги: --check-only (ничего не менять) · --open (открыть нужные сайты в браузере)
set -u

CHECK=0; OPEN=0
for a in "$@"; do case "$a" in --check-only) CHECK=1 ;; --open) OPEN=1 ;; esac; done

LIST=$(claude mcp list 2>/dev/null)
state() {   # печатает: connected | auth | failed | absent
  # имя сервера может идти с префиксом плагина: "plugin:vercel:vercel: https://…"
  local line; line=$(printf '%s' "$LIST" | grep -i "^[a-z0-9 ._:-]*$1[a-z0-9 ._:-]*:" | head -1)
  [ -z "$line" ] && { echo absent; return; }
  case "$line" in
    *"Needs authentication"*) echo auth ;;
    *"Failed to connect"*)    echo failed ;;
    *"Connected"*)            echo connected ;;
    *)                        echo absent ;;
  esac
}

HUMAN=""
need_human() { HUMAN="$HUMAN$1|$2|$3\n"; [ "$OPEN" = 1 ] && command -v open >/dev/null && open "$2" >/dev/null 2>&1; }

printf '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
[ "$CHECK" = 1 ] && printf '🔌  ПРОВЕРЯЮ ДОСТУПЫ  ✨\n' || printf '🔌  ПОДКЛЮЧАЮ ДОСТУПЫ  ⚡\n'
printf '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'

# ---- серверы, которые ставятся без секретов: имя|команда добавления ----
add_plain() {
  local name="$1"; shift
  local st; st=$(state "$name")
  case "$st" in
    connected) printf 'OK %s\n' "$name"; return ;;
    auth)      printf 'AUTH %s\n' "$name"; return ;;
    failed)    printf 'FAILED %s — сервер отвечает ошибкой\n' "$name"; return ;;
  esac
  if [ "$CHECK" = 1 ]; then printf 'DRY %s\n' "$name"; return; fi
  "$@" >/dev/null 2>&1
  LIST=$(claude mcp list 2>/dev/null)
  case "$(state "$name")" in
    connected) printf '+ подключил %s\n' "$name" ;;
    auth)      printf '+ добавил %s (нужен вход)\n' "$name" ;;
    *)         printf '! %s не подключился\n' "$name" ;;
  esac
}

add_plain playwright claude mcp add playwright -s user -- npx -y @playwright/mcp@latest
add_plain vercel     claude mcp add --transport http --scope user vercel https://mcp.vercel.com
add_plain 21st       claude mcp add --transport http --scope user 21st https://21st.dev/api/mcp

# ---- серверы, которые без человека подключить нельзя ----
[ "$(state stitch)" = connected ] && printf 'OK stitch\n' \
  || need_human "Stitch — рисование макетов экранов" \
                "https://stitch.withgoogle.com/docs/mcp/setup/" \
                "адрес сервера выдаётся после входа в Google-аккаунт, у меня его нет"

[ "$(state supabase)" = connected ] && printf 'OK supabase\n' \
  || need_human "Supabase — чтение настоящей схемы базы" \
                "https://supabase.com/dashboard/account/tokens" \
                "нужен личный токен, а токены нельзя пересылать в чат"

# ---- остальные серверы, требующие входа (о своих уже сказано выше) ----
printf '%s' "$LIST" | grep -i 'needs authentication' \
  | grep -viE 'vercel|21st|playwright|stitch|supabase' | while read -r line; do
  printf 'AUTH %s — набери /mcp и подтверди вход\n' "${line%%: http*}"
done

printf '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
if [ -n "$HUMAN" ]; then
  printf 'ЧЕЛОВЕК (что|ссылка|почему не могу сам):\n'
  printf "$HUMAN"
else
  printf 'ГОТОВО — всё, что можно было подключить без тебя, подключено\n'
fi
exit 0
