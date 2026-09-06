#!/usr/bin/env bash
# Самообновление: раз в сутки сверяет установленные скилы с GitHub и обновляет их САМ.
# Личные файлы (уроки, профиль ученика, .state) не трогает.
# Флаги: --now (не ждать суток) · --check-only (только сказать, есть ли новая версия)
set -u
REPO="https://github.com/AzamatRaimbekov/vibe-coding-mentor.git"
SK="$HOME/.claude/skills"
STATE="$SK/vibe-coding-mentor/.state"; mkdir -p "$STATE"
STAMP="$STATE/update-run"; INSTALLED="$STATE/installed-rev"; REPORT="$STATE/update-report.txt"
CACHE="$HOME/.claude/.cache/vibe-coding-mentor-src"
NOW=0; CHECK=0
for a in "$@"; do case "$a" in --now) NOW=1 ;; --check-only) CHECK=1 ;; esac; done

if [ "$NOW" = 0 ] && [ -f "$STAMP" ]; then
  [ $(( $(date +%s) - $(cat "$STAMP" 2>/dev/null || echo 0) )) -lt 86400 ] && exit 0
fi
date +%s > "$STAMP"
command -v git >/dev/null || { printf '! git не найден — обновлять нечем\n' > "$REPORT"; exit 0; }

# 1. свежая копия репозитория в кэше (сеть; поэтому вызывается в фоне)
if [ -d "$CACHE/.git" ]; then
  git -C "$CACHE" fetch -q origin main 2>/dev/null || exit 0
  REMOTE=$(git -C "$CACHE" rev-parse origin/main)
else
  git clone -q --depth 1 "$REPO" "$CACHE" 2>/dev/null || exit 0
  REMOTE=$(git -C "$CACHE" rev-parse HEAD)
fi

# 2. первый запуск: запоминаем текущую версию как установленную, ничего не копируем
if [ ! -f "$INSTALLED" ]; then printf '%s' "$REMOTE" > "$INSTALLED"; : > "$REPORT"; exit 0; fi
[ "$(cat "$INSTALLED")" = "$REMOTE" ] && { : > "$REPORT"; exit 0; }
[ "$CHECK" = 1 ] && { printf 'есть новая версия %s\n' "${REMOTE:0:7}"; exit 0; }

git -C "$CACHE" reset -q --hard "$REMOTE"

# 3. копируем скилы, не трогая личные данные
updated=""
for dir in "$CACHE"/skills/*/; do
  name=$(basename "$dir"); dst="$SK/$name"
  [ -e "$dst" ] || continue                    # человек этот скил не ставил — не навязываем
  if [ -L "$dst" ]; then                       # поставлен через npx skills — обновляет он
    npx -y skills update -g -y >/dev/null 2>&1; updated="$updated $name(skills)"; continue
  fi
  rsync -a --exclude '.state' --exclude 'references/lessons.md' \
        --exclude 'references/student-profile.md' "$dir" "$dst/" && updated="$updated $name"
done

# 4. хуки — только те, что уже подключены
for h in "$CACHE"/hooks/*.sh; do
  t="$HOME/.claude/hooks/$(basename "$h")"
  [ -f "$t" ] && cp "$h" "$t" && chmod +x "$t"
done

printf '%s' "$REMOTE" > "$INSTALLED"
printf '+ обновил до версии %s:%s\n' "${REMOTE:0:7}" "$updated" > "$REPORT"
