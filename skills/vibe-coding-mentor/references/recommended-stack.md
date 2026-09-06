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

## Уровень 1.5. Обвязка агента (harness)

**Harness** — всё, что окружает агента и не даёт ему ошибаться: правила в `CLAUDE.md`,
хуки, проверки перед «готово», память между сессиями. Как кухня, обустроенная так,
чтобы повар не перепутал соль с сахаром. → [что это](https://skills.sh/walkinglabs/learn-harness-engineering/harness-creator)

| Скил | Установок | Зачем | Когда зову |
|------|-----------|-------|------------|
| `walkinglabs/learn-harness-engineering@harness-creator` | 2K | Строит и проверяет обвязку: `CLAUDE.md`, хуки, границы, передача сессии | Агент забывает контекст, выходит за рамки, говорит «готово» до тестов |
| `affaan-m/ecc@eval-harness` | 9.1K | Контрольные задачи для самого агента: не стал ли он хуже после правки правил | Поменял `SKILL.md`, хук или `CLAUDE.md` — прогнать до и после |
| `zernie/vigiles@test-harness` | 1.5K | Проверяет, что хук срабатывает, скил вызывается, подсказка попадает в контекст | Написал новый хук или скил — доказать, что он вообще включается |

```bash
npx skills add walkinglabs/learn-harness-engineering@harness-creator -g -y
npx skills add affaan-m/ecc@eval-harness -g -y
npx skills add zernie/vigiles@test-harness -g -y
```

Для человека без ИТ эти три не называются по имени. Говорится пользой: «проверю,
что новое правило включается», «сравню, не стал ли я хуже после правки».

## Уровень 1.6. Docker

**Docker** — способ упаковать программу вместе со всем, что ей нужно, в один
контейнер, который одинаково запускается на любом компьютере. Как ланч-бокс:
еда, вилка и салфетка внутри, открыл — и ешь где угодно. → [docker.com](https://www.docker.com/get-started/)

| Скил | Установок | Зачем | Когда зову |
|------|-----------|-------|------------|
| `docker-setup` (свой, из этого репо) | — | Ставит Docker с нуля, доводит до зелёного `Hello from Docker!` | Docker не стоит, «кит погас», `cannot connect to the Docker daemon` |
| `github/awesome-copilot@multi-stage-dockerfile` | 23K | Пишет Dockerfile, который собирает маленький и быстрый образ | Нужен Dockerfile или он слишком толстый |
| `affaan-m/ecc@docker-patterns` | 11.2K | Проверяет Dockerfile и compose: безопасность, сети, тома, здоровье сервисов | Ревью контейнеров перед публикацией |
| `manutej/luxor-claude-marketplace@docker-compose-orchestration` | 2.7K | Запускает несколько сервисов вместе: приложение + база + кэш | Чужой проект с `docker-compose.yml`, локальная база |

```bash
npx skills add github/awesome-copilot@multi-stage-dockerfile -g -y
npx skills add affaan-m/ecc@docker-patterns -g -y
npx skills add manutej/luxor-claude-marketplace@docker-compose-orchestration -g -y
```

Агент `docker-engineer` (`~/.claude/agents/devops/docker-engineer.md`) знает,
какой из четырёх звать в какой ситуации; зову его на любую задачу про контейнеры.

## Уровень 1.7. React Native (мобильные приложения)

**React Native** — способ написать одно приложение, которое работает и на iPhone,
и на Android. Как один текст, который печатается и в книге, и на сайте. **Expo** —
набор инструментов вокруг него: показывает приложение на твоём телефоне через
QR-код, не требуя ничего ставить. → [expo.dev](https://docs.expo.dev/)

| Скил | Установок | Зачем | Когда зову |
|------|-----------|-------|------------|
| `vercel-labs/agent-skills@vercel-react-native-skills` | 204K | Экраны, навигация, камера/GPS, правила хорошего кода | Любая новая часть приложения |
| `callstackincubator/agent-skills@react-native-best-practices` | 25K | Скорость: списки, анимации, время открытия | Приложение тормозит или дёргается |
| `google-labs-code/stitch-skills@stitch::react-native` | 6K | Экраны из макета Stitch | Есть дизайн — нужен код |
| `expo/skills@eas-app-stores` | 56K | Сборка на телефон и публикация в App Store / Google Play | Пора отдать приложение людям. **Платно** |

```bash
npx skills add vercel-labs/agent-skills@vercel-react-native-skills -g -y
npx skills add callstackincubator/agent-skills@react-native-best-practices -g -y
npx skills add expo/skills@eas-app-stores -g -y
```

Агент `mobile-engineer` (`~/.claude/agents/mobile/mobile-engineer.md`) выбирает
нужный и предупреждает о платном шаге до его запуска.

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
