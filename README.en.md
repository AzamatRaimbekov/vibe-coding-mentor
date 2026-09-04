# vibe-coding-mentor

**[Русская версия →](README.md)**

[![skills.sh](https://skills.sh/b/AzamatRaimbekov/vibe-coding-mentor)](https://skills.sh/AzamatRaimbekov/vibe-coding-mentor)

A Claude Code skill that **teaches you to build software with an agent** instead of
just handing you code.

It inverts the usual vibe-coding flow: not "agent writes, human agrees", but
"human states and verifies, agent explains and catches".

> **Language:** the skill content is in Russian. Triggers work in both Russian and English.
> **Status:** working, but never pressure-tested with subagents (see Limitations).

## Three skills in this repo

| Skill | Purpose | How to call |
|-------|---------|-------------|
| `vibe-coding-mentor` | Guides step by step, explains, checks understanding | triggers or `/vibe-coding-mentor` |
| `vibecoding` | Project diagnostics: what's missing and what to do | `vibecoding сделай диагностику` |
| `mcp-setup` | Connects access to external services (MCP) | "connect mcp", "design a screen" |

## Install

```bash
npx skills add AzamatRaimbekov/vibe-coding-mentor -g -y            # all skills
npx skills add AzamatRaimbekov/vibe-coding-mentor@vibecoding -g -y # diagnostics only
```

## Tools install themselves

The skill does not report what is missing — it closes the gap. A SessionStart hook
runs delivery in the background: missing plugins and skills are installed, and the
result is announced. For a skill with no known source, the catalog is searched with
`npx skills find` and the top hit is installed only if it has more than 1000 installs —
below that it becomes a question for the human, because a skill runs with full agent
permissions.

Verification is done **on disk, not from installer output**: `npx skills add` can print
an error on a successful install, and an MCP server can report `Connected` with a dead key.

**The human is asked for exactly one thing — a key,** and only where the key exists
solely in their account (Stitch, Supabase). Keys are never requested in chat:

```bash
bash ~/.claude/skills/mcp-setup/scripts/add-key.sh stitch <KEY>
```

The command stores the key in `~/.claude/.secrets/` with `600` permissions and connects
the service immediately.

## Meet Azamat

The skill has a name and a face — **Azamat, your vibe-coding teacher**. On the very
first run it introduces itself before touching the task:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 👋  HI! I'M AZAMAT — YOUR VIBE-CODING TEACHER  ✨
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

I will teach you. Not just write code for you — walk you through it,
explain every decision, and check that it makes sense to you.

🌱 You don't need to be a programmer. I'll explain any unfamiliar word,
and everything we do can be undone. You can't break anything.

Here's what I can do:
🩺 Check your project and tell you what's missing
🎨 Draw screen mockups from a plain description
🌐 Open a site in a browser and show how it actually looks
🗺️ Build a learning roadmap for a profession — from zero to first jobs
🧪 Write checks so code doesn't break silently
🔍 Find an existing solution before inventing one
📦 Find and install the skills I need — you configure nothing
🔌 Connect services myself — deploys, databases, browser
🧠 Remember how you work and write new skills for your tasks

🍀 Good luck! If something is unclear, say so right away.
```

Every bullet is a **benefit, not a tool name**. Not "I can use Playwright MCP", but
"I'll open a site and show how it looks": a tool name tells a beginner nothing,
a benefit tells them everything.

## Always on

`hooks/vibecoding-always.sh` runs on every prompt once wired in:

```bash
mkdir -p ~/.claude/hooks
cp hooks/vibecoding-always.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/vibecoding-always.sh
```

Then add to `hooks.UserPromptSubmit` in `~/.claude/settings.json`:

```json
{ "hooks": [{ "type": "command",
              "command": "bash \"$HOME/.claude/hooks/vibecoding-always.sh\"" }] }
```

The hook stays silent when the skill isn't installed — it breaks nothing on
someone else's machine.

## The loop

One pass = one feature.

| # | Step | Agent | Learner |
|---|------|-------|---------|
| 0 | Level | Asks what's already familiar | Answers honestly |
| 1 | Intent | Helps phrase "done when…" | Writes acceptance criteria |
| 2 | Audit | Runs the project checklist | Picks 1–2 gaps |
| 2.5 | Tooling | Checks MCP, skills, plugins | Decides: fix or work around |
| 2.6 | Sourcing | Finds a skill for the task | Sees what will be used |
| 3 | Boundaries | Shows domain / IO / UI | Says where code goes |
| 4 | **Red test** | Writes a failing test | **Predicts why it fails** |
| 5 | Implementation | Minimal code to green | Reads the diff, names what it does |
| 6 | Verification | Runs commands, shows output | Sees proof |
| 7 | Debrief | 3 lines: learned / shaky / next | Asks questions |

Step 4 is where learning happens. Predicting **before** running builds a mental
model of the code. Agreeing with a finished answer doesn't.

## Announcements

Every tool action is announced **before** it starts, so nobody wonders about the pause:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀  ЗАПУСКАЮ СКИЛ — vibecoding  ✨
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

🚀 running a skill · 🩺 diagnostics · 🔍 searching · 📦 installing ·
🔌 connecting MCP · 🧪 tests · 🗺️ roadmap · ✅ done

Banners are for **tool actions only**. On ordinary replies they become noise
and stop being noticed.

## Does it itself

The learner came to build, not to administer. The skill installs skills, plugins
and MCP servers **itself**, and announces each one:

`✅🎉 Я УСТАНОВИЛ` · `🛠✨ Я СОЗДАЛ` · `🔌⚡ Я ПОДКЛЮЧИЛ` · `🙋⚠️ НУЖЕН ТЫ`

Only the physically impossible is handed back — a **closed list**: browser OAuth,
secret keys, paid subscriptions. And the `🙋 НУЖЕН ТЫ` banner must explain **why
the agent can't do it** — without that it reads as laziness.

**Verify on disk, not by command output.** An installer prints "Installation complete"
and may still put nothing where it belongs — a real case with `npx skills add`, which
spews errors about a foreign format while installing correctly for Claude Code.

## Green and yellow

```
🟢 ХОРОШО ПОЛУЧАЕТСЯ
> You spotted yourself that the price must be copied into the order,
> not referenced. That's exactly the distinction real shops break on.

🟡 ТАК ЛУЧШЕ НЕ ДЕЛАТЬ
> What happened: the stock check and the decrement are two separate steps.
> Risk: two buyers take the last unit at once.
> What to do: merge into one operation — I'll show you.
```

Green names a **specific action**, never the person: "well done" is noise,
"you spotted X" is feedback. Yellow must carry all three parts — without
"what to do" it's a complaint, not teaching. One of each per step.
None at all across a whole step is a red flag: the learner was just agreeing.

## Plain language

Default assumption: **the learner is not a programmer.** Every term is explained on
first use — bold, one sentence, an everyday analogy, a documentation link.
At most two new terms per message.

The words "just" and "obviously" are banned — they mark a skipped explanation.
A command is never given without three things: where to run it, what it does,
what should appear.

**Questions follow the same rules.** A question carries context — why I'm asking,
why now, what happens after — and each option is explained twice: what it is and
what follows from choosing it.

| Bad | Good |
|-----|------|
| "Vitest or Playwright?" | "Check code piece by piece — fast, catches small errors. Or check the whole thing in a real browser — slower, catches what users see" |

A question the person can't possibly answer at their level isn't asked at all:
instead, the fork is explained and one option is recommended with a reason.

## Self-learning

The model isn't retrained — but the instructions the skill runs on accumulate
experience. Two files it maintains itself and reads at the start of every session:

**`references/lessons.md` — its own mistakes.** Strict format: what happened ·
**why it was wrong** · rule for next time. The middle part is mandatory: without it
the specific case is remembered instead of the cause, and the lesson won't transfer.

**`references/student-profile.md` — how to work with this person.** Five sections:
what they know confidently · what's hard · how they like to work · where they're
heading · decisions made.

Entries are **observations, not guesses**: not "probably weak on databases", but
"wrote the race condition guard for stock decrement themselves".

The "what's hard" section ages fastest. When a former difficulty is cleared, the
line moves to "knows" and it's said out loud — the best possible praise, because
it's measurable.

## What it checks

- **Project artifacts** — `references/project-checklist.md`: 8 sections, each item
  with a check command and a "cost of delay" column, so the answer is never
  "that's how it's done" but "here's what will break"
- **MCP servers** — Vercel, Supabase, 21st.dev, with CLI fallbacks. Key insight:
  a missing server is honest, `Needs authentication` **lies** — tools are listed,
  every call fails, and the person goes debugging code instead of authorizing
- **Skills and plugins** — 14 skills by strictness. Missing process core
  (`test-driven-development`, `verification-before-completion`) is a **stop**,
  not a workaround: the loop can't run without them
- **Concepts** — 9 places learners stumble: contracts, layer boundaries, snapshot
  vs reference, races and conditional updates, idempotency, errors as behavior

## Diagnostics: `vibecoding`

```
vibecoding сделай диагностику
```

Runs `scripts/diagnose.sh` — 30+ checks across nine sections: git and secrets ·
reproducibility · scripts · tests · types · failure UX · data · docs · CI.
Project type is auto-detected; nothing crashes the rest.

The report is never a raw table: one summary line → **at most three** "fix now"
items (each phrased as a consequence) → the rest as a backlog → a mandatory
"what's already good" section → one question.

A separate section covers **false positives**: the script checks for files, not
intent. Two invented problems and people stop running it.

`scripts/ensure-tools.sh` checks what the agent can work with at all, and installs
what's missing with `--install`.

## Limitations

- **Not tested.** Per the `writing-skills` methodology a skill should be run against
  subagents to find how they route around its rules. That step was never done.
- **Russian.** The skill body is Russian, which narrows the audience.
- **Claude Code specific.** Checks use `claude mcp list` and the `~/.claude/skills/` layout.

Reports of where the skill fell short are more useful than stars — open an issue.

## License

MIT
