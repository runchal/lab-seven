# Repository Guidelines

## Project Structure & Module Organization
- Root holds static site files; `lab-seven-battery.html` is the production build and should remain dependency-free.
- `lab-seven-battery-editable.html` bundles the in-browser CMS; update shared sections in both files to prevent drift.
- `CLAUDE.md`, `content-editor-guide.md`, `history.md`, and `TODO.md` capture architecture, editing guidance, change logs, and outstanding work.
- `_redirects` and `netlify.toml` configure Netlify routing; keep them in sync when adjusting deployment rules.

## Build, Test, and Development Commands
- `python3 -m http.server 4173` — serve the repository root locally for cross-browser testing.
- `open lab-seven-battery.html` (macOS) or `open -a "Google Chrome" lab-seven-battery-editable.html` for quick spot checks.
- `npx serve .` — alternative static file server when Node.js tooling is preferred.

## Coding Style & Naming Conventions
- Use four-space indentation inside HTML, CSS, and JS blocks; keep styles embedded inside the primary `<style>` tag.
- CSS relies on descriptive, hyphenated class names (e.g. `hero-gradient`) and shared custom properties declared in `:root`.
- JavaScript follows camelCase for variables/functions and keeps logic within the closing `<script>` block; prefer pure functions and early returns.
- Duplicate existing section patterns rather than inventing new ones so typography, spacing, and animations stay consistent.

## Testing Guidelines
- Perform visual QA in Chrome, Safari, and Firefox; verify responsive breakpoints at 480px, 768px, and 1024px using dev tools.
- For editable mode, reset stored content between sessions with `localStorage.removeItem('labSevenCMS')` in the browser console.
- Run Chrome Lighthouse before releases; maintain 90+ scores for Performance, Accessibility, and Best Practices.
- Log major verifications in `history.md` so future contributors understand prior validation coverage.

## Commit & Pull Request Guidelines
- Match the existing history style: imperative subject with optional context after an en dash, e.g. `Add roadmap animation – smooth hero fade`.
- Keep commits focused, include regenerated assets, and avoid tangential refactors.
- PRs must include a concise summary, explicit manual test notes, and links to relevant `TODO.md` items or external tickets.
- Document feature discussions and final decisions in `AGENT-EXCHANGE.md` before opening or merging PRs.
- Provide before/after screenshots (or short clips) for UI moves and call out any content-editor impacts.

## Security & Configuration Tips
- Review `netlify.toml` before changing redirects or headers; mirror updates in `_redirects` when deploying to Netlify.
- Keep all assets self-contained to maintain the site's offline capability and avoid unexpected third-party requests.
- Sanitize new CMS inputs and ensure localStorage keys remain namespaced to `labSeven` to prevent collisions.

## Agent Guardrails & Allowlist
- **Allowed (no approval required)**: `git status`, `git diff`, `git restore --staged`, `rg`, `python3 -m http.server 4173`, `npx serve .`, `open` (for local HTML previews), `./scripts/new-agent-entry.sh`, `./scripts/validate-write-scope.sh`, `./scripts/capture-doc-screens.sh`, `gitleaks detect --no-git --staged`, `npm run format` (targeted files).
- **Requires explicit approval**: `git commit`, `git push`, `git rebase`, `npm install`/`npx` package installs, `brew` commands, networked downloads or API calls, editing outside the repo root, launching browsers with remote URLs.
- **Prohibited**: Modifying `.env*`, `.git/config`, or credential stores; running scripts with `sudo`; deleting user-provided artifacts; expanding write scope beyond what is logged in `AGENT-EXCHANGE.md`.

## Environment Setup
- Preferred runtime: macOS Sonoma / Linux (amd64 or arm64) with Node.js 20.11.x, Python 3.11.x.
- Static site requires no package install; rely on system Python/Node only.
- Keep `prompts/`, `AGENT-EXCHANGE.md`, and automation scripts under version control to preserve reproducibility metadata.

## Verification & CI Expectations
- Before requesting approval, run: `gitleaks detect --no-git --staged`, `npm run lint` (if introduced), `npm test`/Playwright suites once present, manual Lighthouse spot checks, and verify dynamic-range guardrails.
- Document every CI run URL or artifact path inside the entry’s **Implementation & Evidence** section. The 'Dynamic Range Checklist' and 'Guardrail Checklist' must be annotated before sign-off.
- Enforce diff-size ceiling of ±500 lines per entry (unless `[HOTFIX]`); justify any override in the log.

## Write Scope Discipline
- Generate new entries with `./scripts/new-agent-entry.sh` and set precise `files_write_scope` globs.
- Validate every branch prior to review using `./scripts/validate-write-scope.sh AEX-### [base-branch]`.
- If additional files must be touched, update the log first, rerun the validator, and alert collaborating agents before continuing.

- During review, confirm the Agent Exchange 'Dynamic Range' and 'Guardrail' checklists are filled out (content extremes, accessibility, performance, localization, security). If gaps are discovered later, append a post-mortem note and update these guardrails.