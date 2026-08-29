#!/usr/bin/env bash
# Проверяет базовый набор вайбкодера и доставляет недостающее.
# Запуск без аргументов — только проверка. С --install — ставит недостающее.
INSTALL=0; [ "$1" = "--install" ] && INSTALL=1
MISSING=0

say() { printf '%s\n' "$1"; }
have_skill() { [ -d "$HOME/.claude/skills/$1" ]; }
have_plugin() { claude plugin list 2>/dev/null | grep -q "$1"; }
have_mcp() { claude mcp list 2>/dev/null | grep -qi "^$1:"; }

say "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
say "🔌  ПРОВЕРЯЮ БАЗОВЫЙ НАБОР  ✨"
say "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ---------- плагины ----------
for p in superpowers claude-mem frontend-design vercel; do
  if have_plugin "$p"; then
    say "OK|плагин|$p"
  else
    MISSING=$((MISSING+1)); say "НЕТ|плагин|$p"
    [ $INSTALL = 1 ] && claude plugin install "$p@claude-plugins-official" >/dev/null 2>&1 \
      && say "  ✅ Я УСТАНОВИЛ — $p"
  fi
done

# ---------- скилы: имя|источник ----------
while IFS='|' read -r name src; do
  [ -z "$name" ] && continue
  if have_skill "$name"; then
    say "OK|скил|$name"
  else
    MISSING=$((MISSING+1)); say "НЕТ|скил|$name"
    if [ $INSTALL = 1 ]; then
      npx skills add "$src" -g -y >/dev/null 2>&1
      have_skill "$name" && say "  ✅ Я УСТАНОВИЛ — $name" || say "  ⚠️ не встал: $src"
    fi
  fi
done <<'LIST'
agent-browser|vercel-labs/agent-browser
find-skills|vercel-labs/skills@find-skills
graphify|
vibe-coding-mentor|AzamatRaimbekov/vibe-coding-mentor
stitch-generate-design|google-labs-code/stitch-skills
taste-design|google-labs-code/stitch-skills
shadcn-ui|google-labs-code/stitch-skills
LIST

# ---------- MCP ----------
for m in playwright 21st; do
  have_mcp "$m" && say "OK|mcp|$m" || { MISSING=$((MISSING+1)); say "НЕТ|mcp|$m"; }
done
if [ $INSTALL = 1 ] && ! have_mcp playwright; then
  claude mcp add playwright -s user -- npx -y @playwright/mcp@latest >/dev/null 2>&1 \
    && say "  🔌 Я ПОДКЛЮЧИЛ — playwright"
fi

# ---------- требующие человека ----------
claude mcp list 2>/dev/null | grep -i 'needs authentication' | while read -r line; do
  say "ЧЕЛОВЕК|авторизация|${line%%:*}"
done

say "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[ $MISSING = 0 ] && say "✅ ГОТОВО — базовый набор на месте" \
                 || say "⚠️ Не хватает: $MISSING. Запусти с --install"
