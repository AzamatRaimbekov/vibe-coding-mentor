#!/usr/bin/env bash
# Диагностика проекта. Печатает строки вида: СТАТУС|РАЗДЕЛ|ПУНКТ|ДЕТАЛИ
# СТАТУС: OK | WARN | FAIL | SKIP
# Никогда не падает целиком: каждая проверка изолирована.

cd "${1:-.}" 2>/dev/null || { echo "FAIL|Общее|Путь|Каталог не найден: $1"; exit 0; }
R() { printf '%s|%s|%s|%s\n' "$1" "$2" "$3" "$4"; }
has() { [ -e "$1" ]; }
pkg() { [ -f package.json ] && grep -q "\"$1\"" package.json; }

echo "### PROJECT: $(pwd)"

# ---------- тип проекта ----------
TYPE="unknown"
has package.json && TYPE="node"
has package.json && grep -q '"next"' package.json && TYPE="nextjs"
has pyproject.toml && TYPE="python"
has go.mod && TYPE="go"
R OK Общее Тип "$TYPE"

# ---------- git ----------
if git rev-parse --git-dir >/dev/null 2>&1; then
  R OK Git Репозиторий "инициализирован"
  DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  [ "$DIRTY" = "0" ] && R OK Git Дерево "чистое" || R WARN Git Дерево "$DIRTY незакоммиченных файлов"
  has .gitignore && R OK Git gitignore "есть" || R FAIL Git gitignore "нет — мусор и секреты попадут в репозиторий"
  if has .gitignore; then
    grep -qE '(^|/)\.env' .gitignore || R FAIL Git gitignore ".env не игнорируется"
    grep -q 'node_modules' .gitignore || R WARN Git gitignore "node_modules не игнорируется"
  fi
  git ls-files 2>/dev/null | grep -qE '^\.env$|/\.env$' \
    && R FAIL Git Секреты ".env закоммичен в репозиторий" \
    || R OK Git Секреты ".env не закоммичен"
  LEAK=$(git log --all -p -S'API_KEY' --oneline 2>/dev/null | head -3 | wc -l | tr -d ' ')
  [ "$LEAK" != "0" ] && R WARN Git Секреты "в истории есть коммиты со строкой API_KEY — проверить вручную"
  COMMITS=$(git rev-list --count HEAD 2>/dev/null || echo 0)
  R OK Git Коммитов "$COMMITS"
else
  R FAIL Git Репозиторий "не инициализирован — история изменений не ведётся"
fi

# ---------- воспроизводимость ----------
has README.md && R OK Воспроизводимость README "есть" || R FAIL Воспроизводимость README "нет — как запускать проект, нигде не записано"
if [ "$TYPE" = "node" ] || [ "$TYPE" = "nextjs" ]; then
  if has pnpm-lock.yaml || has package-lock.json || has yarn.lock; then
    R OK Воспроизводимость Lockfile "есть"
  else
    R FAIL Воспроизводимость Lockfile "нет — версии зависимостей не зафиксированы"
  fi
  if has .nvmrc || grep -q '"engines"' package.json 2>/dev/null; then
    R OK Воспроизводимость "Версия Node" "зафиксирована"
  else
    R WARN Воспроизводимость "Версия Node" "не зафиксирована — сборка может сломаться при обновлении"
  fi
fi
has .env.example && R OK Воспроизводимость "env.example" "есть" || {
  grep -rqs 'process\.env\.' --include='*.ts' --include='*.tsx' --include='*.js' . 2>/dev/null \
    && R FAIL Воспроизводимость "env.example" "нет, хотя переменные окружения используются" \
    || R SKIP Воспроизводимость "env.example" "переменные окружения не используются"
}

# ---------- скрипты ----------
if has package.json; then
  for s in test lint build; do
    pkg "$s" && R OK Скрипты "$s" "есть" || R WARN Скрипты "$s" "нет команды npm run $s"
  done
  pkg typecheck || pkg types || R WARN Скрипты typecheck "нет отдельной команды проверки типов"
fi

# ---------- тесты ----------
TESTS=$(find . -name node_modules -prune -o -name .next -prune -o \
  \( -name '*.test.*' -o -name '*.spec.*' -o -name 'test_*.py' \) -print 2>/dev/null | wc -l | tr -d ' ')
if [ "$TESTS" = "0" ]; then
  R FAIL Тесты Наличие "тестов нет вообще"
else
  R OK Тесты Наличие "$TESTS файлов"
  NEG=$(grep -rlsE 'rejects|toThrow|assertRaises|expect\(.*\)\.rejects' --include='*.test.*' --include='*.spec.*' . 2>/dev/null | grep -v node_modules | wc -l | tr -d ' ')
  [ "$NEG" = "0" ] && R WARN Тесты "Проверка отказов" "нет ни одного теста на ошибку — покрыт только счастливый путь" \
                   || R OK Тесты "Проверка отказов" "$NEG файлов проверяют ошибки"
  E2E=$(find . -name node_modules -prune -o -name .next -prune -o \( -name 'playwright.config.*' -o -name 'cypress.config.*' \) -print 2>/dev/null | wc -l | tr -d ' ')
  [ "$E2E" = "0" ] && R WARN Тесты E2E "нет тестов, проверяющих приложение целиком" || R OK Тесты E2E "настроены"
fi

# ---------- типы ----------
if has tsconfig.json; then
  grep -q '"strict"[[:space:]]*:[[:space:]]*true' tsconfig.json \
    && R OK Типы strict "включён" \
    || R WARN Типы strict "выключен — часть ошибок TypeScript не ловится"
fi

# ---------- UX отказов (Next.js) ----------
if [ "$TYPE" = "nextjs" ]; then
  D=$(find . -maxdepth 2 -type d -name app -not -path './node_modules/*' 2>/dev/null | head -1)
  if [ -n "$D" ]; then
    has "$D/not-found.tsx"    && R OK "UX отказов" "Страница 404" "есть"    || R FAIL "UX отказов" "Страница 404" "нет — пользователь увидит системный текст"
    has "$D/error.tsx"        && R OK "UX отказов" "Обработка сбоя" "есть"  || R FAIL "UX отказов" "Обработка сбоя" "нет — при ошибке белый экран"
    has "$D/global-error.tsx" && R OK "UX отказов" "Глобальный сбой" "есть" || R WARN "UX отказов" "Глобальный сбой" "нет global-error.tsx"
    has "$D/loading.tsx"      && R OK "UX отказов" "Загрузка" "есть"        || R WARN "UX отказов" "Загрузка" "нет loading.tsx — пустой экран при ожидании"
    grep -rqs 'navigator.onLine\|useOnlineStatus' --include='*.tsx' . 2>/dev/null \
      && R OK "UX отказов" "Нет сети" "обрабатывается" \
      || R WARN "UX отказов" "Нет сети" "потеря связи никак не показывается"
  fi
fi

# ---------- данные ----------
if has prisma/schema.prisma; then
  R OK Данные Схема "prisma/schema.prisma"
  M=$(find prisma/migrations -maxdepth 1 -type d 2>/dev/null | tail -n +2 | wc -l | tr -d ' ')
  [ "$M" = "0" ] && R WARN Данные Миграции "нет — структура базы не версионируется" || R OK Данные Миграции "$M"
  grep -qs '@@unique\|@unique' prisma/schema.prisma \
    && R OK Данные Инварианты "есть уникальные ограничения" \
    || R WARN Данные Инварианты "нет ограничений уникальности — гонки пробьют проверки в коде"
  if grep -qs '"seed"' package.json || ls prisma/seed.* >/dev/null 2>&1; then
    R OK Данные Seed "есть"
  else
    R WARN Данные Seed "нет тестовых данных для локального запуска"
  fi
elif has schema.sql || has migrations; then
  R OK Данные Схема "найдена"
else
  R SKIP Данные Схема "база данных не обнаружена"
fi

# ---------- документация ----------
{ has CLAUDE.md || has AGENTS.md || has .AI.md; } \
  && R OK Документация "Инструкция агенту" "есть" \
  || R WARN Документация "Инструкция агенту" "нет CLAUDE.md — агент каждый раз изобретает стиль заново"
{ has docs/wiki || has docs; } && R OK Документация Каталог "есть" || R WARN Документация Каталог "нет папки docs/"
{ has docs/wiki/decisions || has docs/adr || has docs/decisions; } \
  && R OK Документация ADR "есть" \
  || R WARN Документация ADR "нет записей о принятых решениях — через полгода никто не вспомнит почему так"

# ---------- CI ----------
{ has .github/workflows || has .gitlab-ci.yml; } \
  && R OK CI Автопроверки "настроены" \
  || R WARN CI Автопроверки "нет — «у меня работает» ничем не подтверждается"

echo "### END"
