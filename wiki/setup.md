---
title: Setup & Usage
type: guide
tags: [meta, setup, onboarding, git, workflow]
date: 2026-09-08
sources: [AGENTS.md]
---

# Setup & Usage — How to Set Up and Use This Repo

This is a **persistent, compounding trading wiki** (Karpathy's "LLM Wiki"
pattern). It is owned and maintained by an AI agent working with a human
trader. This page tells anyone — human or agent — how to set it up and use
it. The authoritative schema is [`AGENTS.md`](../AGENTS.md) at the repo
root; this page is the practical walkthrough.

## What this repo is

Three layers:

| Layer | Path | Who owns it | Rule |
|---|---|---|---|
| Raw sources | `raw/` | The human | **Immutable.** Never edit or delete. Source of truth. |
| Wiki pages | `wiki/` | The agent | Living knowledge base; kept consistent. |
| Schema | `AGENTS.md` | The human | Changes only with the human. |

**The core rule: every trade gets ingested and linted.** After every trading
session (demo or real), record what happened, the trade type, and all trader
jargon used — then reconcile it against the rest of the wiki.

## Prerequisites

- **Git 2.x** (Windows: Git for Windows — includes Git Credential Manager)
- A **GitHub account** with access to this repo (it is private)
- **Optional:** Obsidian — open the repo folder as a vault to get the
  wiki-link graph view
- **Optional (for trade data):** MT5 with the `HistoryDump_Zaid` script
  installed (see [Trading data reference](#trading-data-reference))

## First-time setup

### 1. Clone

```powershell
git clone https://github.com/zaidayub143-cmd/Trader-knowledge.git
cd Trader-knowledge
```

### 2. Authenticate — choose ONE of these

**Option A — Git Credential Manager (recommended, browser login):**

```powershell
git config --global credential.helper manager
git credential-manager github login
```

A browser window opens; sign in to GitHub. The token is stored in **Windows
Credential Manager** (local only — never in the repo).

**Option B — Personal Access Token (PAT):**

1. GitHub → **Settings → Developer settings → Personal access tokens →
   Tokens (classic) → Generate new token**
2. Scope: **`repo`** only — nothing more
3. On the next push/pull, paste the token as the password when prompted
   (or run `git credential-manager github login` first).

**Option C — SSH key:**

```powershell
ssh-keygen -t ed25519 -C "your-github-username"
```

Add `~/.ssh/id_ed25519.pub` at GitHub → **Settings → SSH and GPG keys →
New SSH key**, then:

```powershell
git remote set-url origin git@github.com:zaidayub143-cmd/Trader-knowledge.git
```

### 3. Set your identity (one-time, local to this repo)

```powershell
git config user.name "Your Name"
git config user.email "you@example.com"   # or your GitHub noreply email
```

### 4. Verify

```powershell
git pull
```

No error = connected.

## How to use — the workflow

### Ingest a trade session (after every trading day)

1. In MT5, run the `HistoryDump_Zaid` script on the account chart → it
   writes `Account_History.csv` to `MQL5\Files\`.
2. Copy the dump into `raw/trades/YYYY-MM-DD-<account>.csv` — **immutable,
   never edited afterward**.
3. Write `wiki/sources/YYYY-MM-DD-<account>-session.md` covering: what
   happened, each trade (type, entry/exit, SL/TP, result), bot behavior,
   errors, and lessons.
4. Update `wiki/index.md` (add the page + one-line summary).
5. Update/reconcile entity and concept pages; flag any contradiction with
   `> [!warning] Flagged contradiction`.
6. Append an entry to `wiki/log.md` (`## [YYYY-MM-DD] ingest | <Title>`).
7. Commit and push:

```powershell
git add -A
git commit -m "ingest | YYYY-MM-DD <account> session"
git push
```

### Query (answer a question)

1. Read `wiki/index.md` first to find relevant pages.
2. Drill into those pages.
3. Synthesize an answer **with citations** back to sources.
4. File valuable answers back as new pages in `wiki/synthesis/` so
   explorations compound. Update `index.md` and `log.md` accordingly.

### Lint (periodic health check)

Scan for: **contradictions** between pages, **stale claims** superseded by
newer sources, **orphan pages** with no inbound links, **missing
cross-references**, **undefined jargon** (trader terms used but never
defined), and **data gaps** a web search or fresh trade dump could fill.
Report findings with suggestions.

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
  graph view works.
- **Cite sources on claims** (filename or link). Preserve provenance.
- **Jargon rule:** every trader term (SL, TP, RR, BOS, sweep, spread,
  margin, equity, floating P/L, magic number, lot, point, pip…) must be
  defined inline or on a concept page, and linked. The wiki is the glossary
  of record.

## Trading data reference

### Account_History.csv columns (from HistoryDump_Zaid)

`Ticket, PositionID, Symbol, DealType, Entry, Time, Price, Volume, Profit,
Swap, Commission, SL, TP, Magic, Comment`

- `DealType`: `IN` = open, `OUT` = close; `OTHER` = balance ops (deposits,
  transfers).
- `Time` is **server time** (XM = GMT+2/+3, DST-dependent). Local
  (Asia/Kolkata) = server + 2.5h in summer.
- `Magic` = the EA's order tag (e.g. 20260910 for GoldHunterPro_Small).

### Accounts

| | Demo | Real |
|---|---|---|
| Login | 334640751 | 83160890 |
| Server | XMGlobal-MT5 9 | XMGlobal-MT5 4 |
| Type | Standard | Ultra Low Standard |
| Gold symbol | `GOLD` | `Gold.i#` |

The demo's `GOLD` chart stays **black** on the real server — always attach
the EA to `Gold.i#` on the real account.

### Bot (GoldHunterPro_Small)

M1 gold scalper: RSI(14) + EMA 8/21/50 + ATR(14). Magic **20260910**,
MAX_TRADES 2, lot 0.01 (1 oz), SL = max(2.5×ATR, 800 pts ≈ $8), TP = 2× SL
(RR 2.0). Guards: [[Kill Switch]] (+$100 / −$40 daily) and [[Daily Cutoff]]
(18:30 local — closes all, stops the day). Source lives outside the repo at
`C:\Users\Supertails PRM\Desktop\GoldHunterPro_Zaid_Small.mq5`.

## Safety rules

- **Never commit credentials.** No passwords, tokens, API keys, or
  `Account_Info.csv` snapshots. The `.gitignore` blocks the common patterns
  (`.env`, `*.pem`, `*.key`, `*token*`, `*password*`, `*.dat`).
- **`raw/` is immutable** — never edit or delete files there.
- **No secrets in wiki pages** — account *login numbers* are identifiers,
  not secrets, but keep passwords and tokens out entirely.
- **`AGENTS.md` changes only with the human.**

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Invalid username or token` on push/pull | Run `git credential-manager github login` (or re-enter a PAT) |
| `LF will be replaced by CRLF` warnings | Harmless (Windows line endings); ignore |
| `Push rejected` (non-fast-forward) | `git pull --rebase` then push again |
| `repository not found` | You lack access to the private repo — ask the owner to add you |
| Forgot identity | `git config user.name` / `user.email` (local) |

## Related

- [[2026-09-08 Real Session]] — example of a fully ingested session
- [[XM Accounts]] — account details and jargon
- [[GoldHunterPro Small]] — the live bot
- [[Risk Reward]] — the risk math behind every trade