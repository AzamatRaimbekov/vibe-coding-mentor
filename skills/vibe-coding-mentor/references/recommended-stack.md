# Что должно стоять у вайбкодера

Подборка собрана фактическим поиском по `npx skills find`, **снимок на 28 августа 2026**.
Числа установок стареют, названия меняются, репозитории переименовывают.

**Перед установкой всегда проверяй актуальность поиском.** Список ниже — стартовая
точка, а не истина. Если установка падает с «No matching skills found» — скил
переименовали: склонируй репозиторий и посмотри реальные имена папок.

Большие числа установок означают популярность, **не качество**. Скил выполняется
с полными правами агента — открывай `SKILL.md` глазами перед установкой.

## Уровень 0. Плагины — ставить первыми

Это не скилы, ставятся другой командой и приносят сразу пачку возможностей.

```bash
claude plugin install superpowers@claude-plugins-official
claude plugin install claude-mem@thedotmack
claude plugin install frontend-design@claude-plugins-official
claude plugin install vercel@claude-plugins-official
```

| Плагин | Зачем вайбкодеру |
|--------|------------------|
| `superpowers` | Процессное ядро: brainstorming, writing-plans, TDD, systematic-debugging, verification-before-completion. **Без него нет дисциплины вообще** |
| `claude-mem` | Память между сессиями. Без неё каждый заход начинается с нуля |
| `frontend-design` | Интерфейсы перестают выглядеть шаблонными |
| `vercel` | MCP для деплоя, логов и переменных окружения |

Проверить установленное: `claude plugin list`.

Скилы Anthropic (`frontend-design`, `artifact-*`, `dataviz`) приходят **плагинами**,
а не через `npx skills find` — искать их в каталоге бесполезно.

## Уровень 1. Обязательный минимум

Четыре вещи, которых не хватает почти каждому проекту на вайбкодинге.

| Скил | Установок | Зачем |
|------|-----------|-------|
| `vercel-labs/agent-skills@deploy-to-vercel` | 115.7K | Публикация проекта. Официальный, самый популярный скил экосистемы |
| `addyosmani/web-quality-skills@accessibility` | 48.2K | Доступность интерфейсов. Автор — Addy Osmani из команды Chrome |
| `trkbt10/indexion-skills@indexion-readme` | 5.1K | README, которого нет у 90% вайбкод-проектов |
| `open-mercato/skills@om-root-cause` | 743 | Поиск причины бага вместо лечения симптома |

```bash
npx skills add vercel-labs/agent-skills@deploy-to-vercel -g -y
npx skills add addyosmani/web-quality-skills@accessibility -g -y
npx skills add trkbt10/indexion-skills@indexion-readme -g -y
npx skills add open-mercato/skills@om-root-cause -g -y
```

## Уровень 2. Под стек

Ставить только то, на чём реально пишешь.

**TypeScript / React / Next.js**

| Скил | Установок |
|------|-----------|
| `wshobson/agents@typescript-advanced-types` | 67.3K |
| `dotneet/claude-code-marketplace@typescript-react-reviewer` | 8.2K |
| `sickn33/agentic-awesome-skills@react-nextjs-development` | 1.7K |

**Качество и безопасность**

| Скил | Установок |
|------|-----------|
| `waybarrios/opencode-power-pack@security-review` | 542 |
| `hieutrtr/ai1-skills@code-review-security` | 427 |
| `dembrandt/dembrandt-skills@performance-and-web-vitals` | 637 |
| `dzhng/skills@refactor-clean` | 185 |

**Работа с Git и командой**

| Скил | Установок |
|------|-----------|
| `github/awesome-copilot@commit-message-storyteller` | 329 |
| `neolabhq/context-engineering-kit@attach-review-to-pr` | 990 |

**Документация**

| Скил | Установок |
|------|-----------|
| `boshu2/agentops@doc` | 1.4K |

## Уровень 3. Свои

| Скил | Зачем |
|------|-------|
| `vibe-coding-mentor` | Ведёт по шагам, объясняет, строит роадмап |
| `vibecoding` | Диагностика проекта: чего нет и что делать |

```bash
npx skills add AzamatRaimbekov/vibe-coding-mentor -g -y
```

## Чего в подборке нет и почему

**Тесты.** Поиск по «testing» выдаёт скилы под конкретные стеки — Spring Boot, iOS,
Java. Универсального хорошего нет. Работает `test-driven-development` из `superpowers`.

**База данных.** Найденное (`bytebase/dbhub` 440, `lobehub@db-migrations` 203) заточено
под чужие инструменты. Под свой стек ищи отдельно.

**Планирование.** Всё найденное слабее `brainstorming` и `writing-plans` из `superpowers`.

## Порядок установки

Не ставь всё сразу. Порядок такой:

1. Плагины (уровень 0) — они дают основу
2. Обязательный минимум (уровень 1) — четыре скила
3. **Работай.** Что реально понадобится, станет видно через неделю
4. Уровень 2 — по мере надобности, под конкретную задачу

Тридцать установленных скилов не делают кодером. Четыре используемых — делают.

## Что говорить ученику

Не вываливай список целиком. Назови два-три под его задачу и скажи, что каждый даёт:

> Ставлю `deploy-to-vercel` — он знает, как опубликовать проект и что проверить перед
> публикацией. И `accessibility` — проверит, что сайтом смогут пользоваться люди
> с плохим зрением и без мышки.
