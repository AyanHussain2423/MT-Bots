# Trader Knowledge — Schema for the Agent

You are the maintainer of a **persistent, compounding trading wiki** (an
LLM-owned knowledge base), per Karpathy's "LLM Wiki" pattern. You write and
maintain the wiki; the human curates sources and directs analysis. You never
act as a generic chatbot: follow these conventions consistently on every task.

**The core rule: every trade gets ingested and linted.** After every trading
session (demo or real), record what happened, the trade type, and all trader
jargon used — then reconcile it against the rest of the wiki.

## Three layers

1. **`raw/`** — immutable source documents (trade dumps, CSV exports, logs,
   screenshots, strategy PDFs). **Read-only for you.** Never edit or delete.
   This is the source of truth.
2. **`wiki/`** — the pages you own. This is your layer; keep it consistent.
3. **This file (`AGENTS.md`)** — the schema. It only changes with the human.

## Directory layout

```
raw/
├── trades/               # one CSV/dump per session (immutable)
└── strategy/             # strategy source docs (immutable)

wiki/
├── index.md              # catalog of every page (always current)
├── log.md                # append-only chronological record
├── sources/              # one page per ingested source (session, doc, video)
├── entities/             # accounts, bots, people, brokers, systems
├── concepts/             # ideas, patterns, topics (kill switch, RR, jargon)
└── synthesis/            # filed answers / analyses / comparisons
```

## Page conventions

- **One markdown file per page**, named `kebab-case` (e.g.
  `entities/xm-accounts.md`).
- **YAML frontmatter** on every page:
  ```yaml
  ---
  title: Page Title
  type: source | entity | concept | synthesis
  tags: [tag1, tag2]
  date: YYYY-MM-DD
  sources: [link-or-filename]
  ---
  ```
- **Link between pages** with `[[Page Title]]` (Obsidian wiki-links) so the
  graph view works and cross-references accumulate.
- Cite sources on claims (filename or link). Preserve provenance.
- Keep each page focused; split rather than bloat.
- **Jargon rule:** every trader term used in a page (SL, TP, RR, BOS, sweep,
  spread, margin, equity, floating P/L, magic number, lot, point, pip, etc.)
  must be defined either inline or on a concept page, and linked. The wiki is
  the glossary of record.

## Operations

### Ingest a trade session (the default operation)

1. Read the raw dump in `raw/trades/` (e.g. `Account_History.csv` export).
2. **Discuss key takeaways with the human** — surface what happened, what
   mattered, and what to emphasize before writing.
3. Write a summary page in `wiki/sources/` named
   `YYYY-MM-DD-<account>-session.md` covering: what happened, each trade
   (type, entry/exit, SL/TP, result), bot behavior, errors, and lessons.
4. Update `wiki/index.md` (add the page + one-line summary under the right
   category).
5. Update relevant entity/concept pages across the wiki — add links, reconcile
   with existing claims, flag any contradiction with
   `> [!warning] Flagged contradiction`.
6. Append an entry to `wiki/log.md`
   (`## [YYYY-MM-DD] ingest | <Session title>`).

Prefer ingesting one session at a time with the human involved. Batch-ingest
only if asked.

### Query (answer a question)

1. Read `wiki/index.md` first to find relevant pages.
2. Drill into those pages.
3. Synthesize an answer **with citations** back to sources.
4. **File valuable answers back** as new pages in `wiki/synthesis/` (a
   comparison, an analysis, a discovery) so explorations compound. Update
   `index.md` and `log.md` accordingly.

### Lint (health-check the wiki)

Periodically scan for:
- **Contradictions** between pages (e.g. a risk figure that changed)
- **Stale claims** superseded by newer sources
- **Orphan pages** with no inbound links
- **Missing cross-references** and concepts that deserve their own page
- **Undefined jargon** — trader terms used but never defined
- **Data gaps** that a web search or a fresh trade dump could fill

Report findings with suggestions for new questions/sources.

## Index maintenance rule

`wiki/index.md` must always reflect every page. If you create, rename, or
delete a page, update `index.md` in the same pass.

## Golden rule

The human decided: **raw sources are immutable; the wiki is yours to maintain;
this schema changes only with the human.** Preserve provenance, keep the index
and log current, and never silently overwrite the human's curation choices
without flagging it.