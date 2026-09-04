#!/usr/bin/env bash
# Ставит недостающие плагины и скилы САМ. Ничего не спрашивает.
# Незнакомый скил ищет через `npx skills find` и ставит верхний надёжный результат.
# Флаги: --dry-run  --with-stack  --quiet  --once (не чаще раза в сутки)
set -u

DRY=0; STACK=0; QUIET=0; ONCE=0
for a in "$@"; do case "$a" in
  --dry-run) DRY=1 ;; --with-stack) STACK=1 ;; --quiet) QUIET=1 ;; --once) ONCE=1 ;;
esac; done

SKILLS_DIR="$HOME/.claude/skills"
CACHE_DIR="$HOME/.claude/plugins/cache"
STATE_DIR="$HOME/.claude/skills/vibe-coding-mentor/.state"
STAMP="$STATE_DIR/last-run"
LOG="$STATE_DIR/last-report.txt"
MIN_INSTALLS=1000          # порог доверия к находке из каталога
mkdir -p "$STATE_DIR"

if [ "$ONCE" = 1 ] && [ -f "$STAMP" ]; then
  now=$(date +%s); then_=$(cat "$STAMP" 2>/dev/null || echo 0)
  [ $((now - then_)) -lt 86400 ] && exit 0
fi

installed=(); failed=(); risky=()
say() { [ "$QUIET" = 1 ] || printf '%s\n' "$*"; printf '%s\n' "$*" >> "$LOG.tmp"; }
: > "$LOG.tmp"

# --- плагины -----------------------------------------------------------------
PLUGINS=(
  "superpowers@claude-plugins-official"
  "claude-mem@thedotmack"
  "frontend-design@claude-plugins-official"
  "vercel@claude-plugins-official"
)
MARKETPLACES=("claude-plugins-official=anthropics/claude-plugins-official" "thedotmack=thedotmack/claude-mem")

plugin_present() {   # по локальному реестру — быстро, без запуска claude
  local n="${1%@*}"
  grep -q "\"$n@" "$HOME/.claude/plugins/installed_plugins.json" 2>/dev/null && return 0
  ls -d "$HOME/.claude/plugins"/*/*/"$n" >/dev/null 2>&1
}

for m in "${MARKETPLACES[@]}"; do
  name="${m%%=*}"; repo="${m#*=}"
  claude plugin marketplace list 2>/dev/null | grep -q "❯ $name" && continue
  [ "$DRY" = 1 ] && { say "DRY marketplace $name"; continue; }
  claude plugin marketplace add "$repo" >/dev/null 2>&1
done

for p in "${PLUGINS[@]}"; do
  if plugin_present "$p"; then say "OK plugin ${p%@*}"; continue; fi
  if [ "$DRY" = 1 ]; then say "DRY plugin $p"; continue; fi
  claude plugin install "$p" >/dev/null 2>&1
  if plugin_present "$p"; then installed+=("плагин ${p%@*}"); say "INSTALLED plugin ${p%@*}"
  else failed+=("плагин $p"); say "FAILED plugin $p"; fi
done

# --- скилы -------------------------------------------------------------------
skill_present() {
  [ -d "$SKILLS_DIR/$1" ] && return 0
  [ -d ".claude/skills/$1" ] && return 0
  [ -d "$CACHE_DIR" ] && find "$CACHE_DIR" -maxdepth 5 -type d -name "$1" -print -quit 2>/dev/null | grep -q . && return 0
  return 1
}

# ищет в каталоге и печатает "источник<TAB>установок" для верхнего результата
lookup() {
  npx -y skills find "$1" 2>/dev/null \
    | sed 's/\x1b\[[0-9;]*m//g' \
    | grep -E '^[A-Za-z0-9_.-]+(/[A-Za-z0-9_.-]+)?(@[A-Za-z0-9_.-]+)? +[0-9.]+K? installs?' \
    | head -1 \
    | awk '{n=$2; sub(/K$/,"",n); if ($2 ~ /K$/) n=n*1000; print $1 "\t" int(n)}'
}

install_skill() {   # $1 имя папки, $2 источник ("" = искать в каталоге)
  local name="$1" src="$2" hits=""
  skill_present "$name" && { say "OK skill $name"; return; }
  if [ -z "$src" ]; then
    [ "$DRY" = 1 ] && { say "DRY lookup $name"; return; }
    local found; found=$(lookup "$name")
    if [ -z "$found" ]; then failed+=("скил $name — в каталоге не найден"); say "FAILED skill $name (не найден)"; return; fi
    src=$(printf '%s' "$found" | cut -f1); hits=$(printf '%s' "$found" | cut -f2)
    if [ "${hits:-0}" -lt "$MIN_INSTALLS" ]; then
      risky+=("$name → $src ($hits установок)"); say "RISKY skill $name $src $hits"; return
    fi
    say "FOUND skill $name → $src ($hits установок)"
  fi
  [ "$DRY" = 1 ] && { say "DRY skill $src"; return; }
  npx -y skills add "$src" -g -y >/dev/null 2>&1
  if skill_present "$name"; then installed+=("скил $name"); say "INSTALLED skill $name"
  else failed+=("скил $name ($src)"); say "FAILED skill $name"; fi
}

# имя_папки=источник  (пусто = найти в каталоге автоматически)
CORE=(
  "using-superpowers=" "brainstorming=" "writing-plans="
  "test-driven-development=" "systematic-debugging="
  "verification-before-completion=" "project-documentation-wiki="
  "find-skills=vercel-labs/skills"
  "vibecoding=AzamatRaimbekov/vibe-coding-mentor"
  "mcp-setup=AzamatRaimbekov/vibe-coding-mentor"
)
STACK_SKILLS=(
  "agent-browser=vercel-labs/agent-browser"
  "stitch-generate-design=google-labs-code/stitch-skills"
  "taste-design=google-labs-code/stitch-skills"
  "shadcn-ui=google-labs-code/stitch-skills"
  "deploy-to-vercel=vercel-labs/agent-skills@deploy-to-vercel"
  "accessibility=addyosmani/web-quality-skills@accessibility"
  "indexion-readme=trkbt10/indexion-skills@indexion-readme"
  "om-root-cause=open-mercato/skills@om-root-cause"
)
TARGETS=("${CORE[@]}"); [ "$STACK" = 1 ] && TARGETS+=("${STACK_SKILLS[@]}")

for entry in "${TARGETS[@]}"; do install_skill "${entry%%=*}" "${entry#*=}"; done

# --- итог --------------------------------------------------------------------
say "---"
say "SUMMARY installed=${#installed[@]} failed=${#failed[@]} risky=${#risky[@]}"
for i in ${installed[@]+"${installed[@]}"}; do say "+ $i"; done
for f in ${failed[@]+"${failed[@]}"};       do say "! $f"; done
for r in ${risky[@]+"${risky[@]}"};         do say "? $r — мало установок, ставить только с ведома человека"; done
[ ${#installed[@]} -gt 0 ] && say "RESTART нужен /clear — новые скилы читаются при старте сессии"

mv "$LOG.tmp" "$LOG"; date +%s > "$STAMP"
exit 0
