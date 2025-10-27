# Agent Exchange Log (Template v2.0)

## Purpose
Shared architecture decision record (ADR) for every Codex ↔ Claude collaboration cycle. Each entry captures reproducibility data, consensus checkpoints, implementation scope, and verification so future contributors can replay decisions without dredging chat logs.

## Role Definitions
- **Primary Agent** – Implements code for the current request. Either Codex or Claude can serve as primary per entry.
- **Secondary Agent** – Provides analysis, tests, and reviews. Advises the primary and maintains guardrails.
- **User / Requester** – Defines goals, resolves deadlocks, and signs off on delivery.

Agents may swap roles between entries, but primary status must be explicit in the log.

## Reproducibility Requirements
- Pin the exact model, version/endpoint, temperature/top-p, and toolchain versions used by both agents.
- Record the runtime image (Docker tag, devcontainer hash, or environment snapshot) and any local overrides.
- Store prompts/system modifiers used for planning or implementation alongside the entry (link or file path).

## Guardrails & Allowed Operations
- Maintain a command/tool allowlist per repository (e.g., lint, test, build, git status, format). Reference it from each entry via `allowlist`.
- Prohibit network writes, package upgrades, database migrations, or environment mutations without explicit ✅ user approval.
- Require secret scanning (`gitleaks` or equivalent) and SBOM/Licence checks before merge.

## Branching, Locks, & File Scope
- Create a dedicated branch per entry: `agent/<primary>/<ticket-or-slug>`.
- Declare `files_write_scope` to reserve file globs for the primary. Secondary agents must not edit outside the declared scope.
- Register any conflicting locks in the log so parallel work can re-sequence safely.

## Workflow Loop
1. **Log Request** – Open an entry (status `drafting`) with YAML front matter and initial constraints.
2. **Secondary Proposal** – Secondary agent defines approach, assumptions, acceptance criteria, and a failing/regression test to start from.
3. **Primary Response** – Primary evaluates the plan, adds concerns, and confirms test strategy (begin by implementing/adjusting the failing test).
4. **Consensus Check** – Iterate proposal/response up to two cycles. If still ❌ Blocked, escalate to the user with a pros/cons summary.
5. **Implementation & Verification** – Primary commits changes under the scoped branch, runs `./scripts/validate-write-scope.sh <entry-id>`, and references tests, CI runs, and diff links. Secondary reviews the diff (not full files) and runs any additional checks.
6. **User Decision** – User records approval, overrides, or follow-up tasks. CI (lint/type/unit/e2e/secret-scan/license/sbom) must be green unless `[HOTFIX]`.

## Status, Priority & Metadata Values
- **Status**: `drafting`, `proposal-pending`, `in-progress`, `review`, `approved`, `deferred`, `rejected`, `stale`, `timebox-exceeded`
- **Priority**: `low`, `medium`, `high`, `blocking`
- **Scope**: `single-file`, `component`, `architecture`
- **Code Location**: `main`, `prototype/<folder>`, `hotfix`
- **Agreement Level**: ✅ Agreed | ⚠️ Acceptable with caveats | ❌ Blocked

## Entry Structure
Each entry begins with YAML front matter followed by the narrative sections.

```
---
id: AEX-###
date: YYYY-MM-DD
requester: @username
dri: @primary-agent
primary: claude | codex
secondary: codex | claude
branch: agent/<primary>/<slug>
files_write_scope:
  - path/glob/**
status: drafting | proposal-pending | in-progress | review | approved | deferred | rejected | stale
priority: low | medium | high | blocking
scope: single-file | component | architecture
code_location: main | prototype/<folder> | hotfix
# Optional cross-links
migrates_from: AEX-###            # when migrating prototype -> production
ci_backfill_deadline: 2025-01-16T12:00:00Z  # required for [HOTFIX] entries
consensus_cycles:
  - timestamp: 2025-01-15T14:30:00Z
    outcome: ⚠️ Concerns
model_ctx:
  primary: {model: name, endpoint: url, temperature: 0.2, top_p: 0.9}
  secondary: {model: name, endpoint: url, temperature: 0.2, top_p: 0.9}
environment:
  image: repo/devcontainer:tag
  tools:
    - node@20.11
    - python@3.11.6
    - pnpm@8.15
assumptions:
  - Constraint or promise
timebox_hours: #
allowlist:
  - npm run lint
  - npm run test:e2e
  - git status
acceptance_criteria:
  - Expected behaviour statement
tests:
  - path/to/test.spec.ts (initial: failing)
ci_gates:
  - lint
  - unit
  - e2e
  - secret-scan
  - sbom
  - license
  - diff-size
risk: low | medium | high
impact: brief description
rollback: revert PR #xxxx or instructions
data_bounds:
  content_length: {min: , max: }
  numeric_range: {min: , max: }
  asset_size: {max_kb: }
  notes: 
---

## Request
- Summary: …
- Constraints: …
- Assets / Links: …

## Secondary Proposal
- Approach: …
- Assumptions: …
- Test Plan: failing test name or strategy …
- Open Questions: …

## Primary Response
- Assessment: ✅ Good | ⚠️ Concerns | 🛑 Objection
- Feedback: …
- Alternative (if any): …
- Test Execution: Added/updated test results …

## Consensus
- Agreement Level: ✅ Agreed | ⚠️ Acceptable with caveats | ❌ Blocked
- Dynamic Range Checklist: content variants reviewed ✅ / needs follow-up ⚠️ (list extreme cases)
- Guardrail Checklist: security, accessibility, performance, and localization reviewed ✅ / needs follow-up ⚠️
- Trade-offs & Risks: …
- Recommended Path: …

> **Agreement Level guidance**  
> ✅ Agreed — both agents aligned; no outstanding concerns.  
> ⚠️ Acceptable with caveats — proceed, but document risks or follow-up tasks.  
> ❌ Blocked — unresolved objections; halt until the user resolves or overrides.

## Implementation & Evidence
- Branch: `agent/<primary>/<slug>`
- Diff Review: link to `git diff` / PR / patch
- Diff Size: +X/-Y lines (flag if above limit)
- Files Affected: `path/to/file`, `another/file`
- Tests Added/Updated: …
- CI Status: lint ✅ | unit ✅ | e2e ✅ | secret-scan ✅ | sbom ✅ | license ✅
- SBOM / Reports: links or artifact paths

## User Decision
- Decision: Approved | Rejected | Deferred | Override
- Notes: …
- Follow-ups: …

## Notes
- Related Docs: TODO.md line X, history.md YYYY-MM-DD, ADR-001
- Missed Scenario Review: If a defect escapes consensus, log a post-mortem (what was missed, why, and process updates)
- Supersedes: Entry YYYY-MM-DD (if applicable)
- Conflicts: Entry YYYY-MM-DD (if overlapping)
- Prompt Archive: path to stored prompts/system files

## Rollback Plan
- Summary: steps to revert safely
- Owners: …
- Verification After Rollback: tests to re-run
```

### Sample Entry
```
---
id: AEX-012
date: 2025-01-15
requester: @amit
dri: @claude
primary: claude
secondary: codex
branch: agent/claude/hero-refresh
files_write_scope:
  - prototype/hero/**
  - prototype/styles/**
status: drafting
priority: high
scope: component
code_location: prototype/hero-refresh
migrates_from: null
ci_backfill_deadline: null
consensus_cycles:
  - timestamp: 2025-01-15T09:00:00Z
    outcome: ⚠️ Concerns
model_ctx:
  primary: {model: claude-3.7, endpoint: https://api.anthropic.com/v1/messages, temperature: 0.2, top_p: 0.8}
  secondary: {model: gpt-5-thinking, endpoint: https://api.openai.com/v1/responses, temperature: 0.25, top_p: 0.9}
environment:
  image: fieldpack/web:2025-01-12
  tools:
    - node@20.11.1
    - pnpm@8.15.4
    - playwright@1.41.1
assumptions:
  - No third-party fonts may be bundled without legal clearance.
  - Prototype updates stay isolated from production release branch.
timebox_hours: 3
allowlist:
  - pnpm test --filter hero
  - pnpm lint
  - git status
acceptance_criteria:
  - New hero matches Figma layout at 1440px ±2px tolerance.
  - Existing hero animation timing preserved (<5% delta).
tests:
  - prototype/tests/hero-layout.spec.ts (initial: failing)
ci_gates:
  - lint
  - unit
  - e2e
  - secret-scan
  - sbom
  - license
  - diff-size
risk: medium
impact: visual regression risk in prototype; no production exposure.
rollback: revert PR #452 or reset branch `agent/claude/hero-refresh`.
data_bounds:
  content_length: {min: 12, max: 48}
  numeric_range: {min: 0, max: 100}
  asset_size: {max_kb: 200}
  notes: prototype copy pulls from marketing CMS variants.
---

## Request
- Summary: Integrate the latest Figma hero export into the prototype while keeping current animation timings.
- Constraints: No production release; maintain existing typography tokens.
- Assets / Links: `figma-exports/hero-refresh.zip`, Figma file link.

## Secondary Proposal
- Approach: Diff export against prototype, reuse existing CSS variables, and generate a regression Playwright test capturing hero layout.
- Assumptions: Export contains HTML/CSS only; no new JS dependencies.
- Test Plan: Add failing Playwright spec `prototype/tests/hero-layout.spec.ts`.
- Open Questions: Do we adopt marketing copy v3 or stay with v2?

## Primary Response
- Assessment: ⚠️ Concerns
- Feedback: Export bundles custom fonts; licensing unresolved. Prefer rebuilding with utility classes.
- Alternative: Implement layout with existing utility classes; document copy decisions separately.
- Test Execution: Added test in red; confirms layout mismatch vs. baseline.

## Consensus
- Agreement Level: ⚠️ Acceptable with caveats
- Trade-offs & Risks: Longer dev time to re-map classes; typography risk mitigated by utility usage.
- Recommended Path: Rebuild hero using utility classes, obtain copy confirmation pre-merge, keep fonts untouched.
- Guardrail Checklist: security ✅ | accessibility ⚠️ (requires screen-reader test) | performance ✅ | localization ⚠️ (await translation check)

## Implementation & Evidence
- Branch: `agent/claude/hero-refresh`
- Diff Review: PR #452 (`git show --stat`)
- Files Affected: `prototype/hero/index.html`, `prototype/styles/hero.css`
- Tests Added/Updated: `prototype/tests/hero-layout.spec.ts`
- CI Status: lint ✅ | unit ✅ | e2e ✅ | secret-scan ✅ | sbom ✅ | license ✅
- SBOM / Reports: `artifacts/sbom-2025-01-15.json`, `artifacts/gitleaks-report.txt`

## User Decision
- Decision: Approved
- Notes: Marketing copy to be revisited once legal approves fonts.
- Follow-ups: Create entry for production integration after prototype sign-off.

## Notes
- Related Docs: TODO.md line 42, history.md 2025-01-14, ADR-005
- Supersedes: n/a
- Missed Scenario Review: dynamic range checks validated against CMS variants
- Conflicts: Entry AEX-009 (prototype animation audit)
- Prompt Archive: `prompts/2025-01-15-hero-refresh/`

## Rollback Plan
- Summary: Revert PR #452, purge prototype layout cache, re-run Playwright suite.
- Owners: @claude executes revert; @codex verifies tests.
- Verification After Rollback: `pnpm test --filter hero`, manual visual check at 1440px.
```

## Usage Notes
- Append new entries directly below the marker in reverse chronological order.
- Store prompt files referenced in **Prompt Archive** under version control for replayability.
- Secondary agent must produce acceptance criteria and failing tests before primary begins implementation.
- Reviews occur on diffs only (`git diff`, PR view); avoid full-file rewrites unless justified in the log.
- Mark entry `stale` after 14 days of inactivity; revisit during weekly triage to close or re-timebox.
- Update `status`/`priority`/`scope` fields in the front matter as the work progresses.
- Log each proposal/response pass under `consensus_cycles` with timestamps for traceability.
- Run `./scripts/validate-write-scope.sh <entry-id>` before requesting review to confirm no files escape the declared scope.
- Capture verification screenshots with `./scripts/capture-doc-screens.sh` (requires `npx capture-website`) and attach paths under **Implementation & Evidence** when visual changes are involved.
- Document outcomes of the Dynamic Range and Guardrail checklists (security, accessibility, performance, localization) before requesting user approval.

## Edge Cases & Protocols
- **Disagreement Resolution**: After two unresolved cycles, escalate to the user with a comparative table of options.
- **Emergency / Hotfix**: Execute immediately, set `ci_backfill_deadline`, record `[HOTFIX]` in the title, and backfill CI artifacts within 24 hours (log results in a follow-up entry if needed).
- **Implementation Drift**: Primary creating new scope must open a follow-up entry referencing the original.
- **Security & Secrets**: Never touch `.env*` or secrets storage. Run `gitleaks detect --no-git --staged` (or configured scanner) on every branch before requesting approval.
- **Prototype to Production**: Log a second entry for migration, populate `migrates_from`, and link entries via **Supersedes**.
- **Timebox Enforcement**: If `timebox_hours` expires, update status to `timebox-exceeded`, halt work, and obtain user direction before resuming.

## Archival & Indexing
- Archive entries older than 90 days into `AGENT-EXCHANGE-ARCHIVE.md`, grouped by subsystem (e.g., `web/hero`, `api/auth`).
- Link archived entries to formal ADRs when the decision impacts long-term architecture.

## Related Documents
- `AGENTS.md` – Agent capabilities, guardrails, and commit workflow.
- `AGENT-COLLAB-PLAYBOOK.md` – Transportable dual-agent operations guide.
- `CLAUDE.md` – Architectural guidance and implementation principles.
- `TODO.md` – Active task list with priorities.
- `history.md` – Detailed session logs and verification records.

## Entries



> Insert newest entries directly below this callout.
