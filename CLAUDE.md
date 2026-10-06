# Sovereign AI explorer · agent rules

Sovereign AI explorer (working name) is a desktop app for owning the models you use: find open-weight language models on Hugging Face, download them, run them on your own machine, learn what the parameters mean, keep presets, and measure what every answer costs. Tauri with a Rust backend and a Svelte UI. Built in public by Leo Xeno. All rights reserved.

This file is the stable root of the spec tree. It changes rarely. Everything that changes often lives in a linked file. `AGENTS.md` is a symlink to this file; `scripts/check.sh` fails if they drift.

## The one rule

**The repository is the source of truth, not the chat.** A requirement that exists only in a conversation does not exist. Write it into a spec, an ADR, or an issue before acting on it.

## Read on demand

| When you are about to… | Read first |
|---|---|
| Do anything | this file, then [docs/STATUS.md](docs/STATUS.md) for where we are and what is next |
| Touch product scope, stages or build order | [docs/PRODUCT.md](docs/PRODUCT.md) |
| Argue about why this app exists | [docs/VISION.md](docs/VISION.md) |
| Change structure, process boundaries, storage or the engine | [docs/decisions/0001-stack.md](docs/decisions/0001-stack.md), then the ADR that owns the area |
| Touch anything visual | [docs/design/DESIGN-DECISIONS.md](docs/design/DESIGN-DECISIONS.md) |
| Build a feature | its spec in [docs/specs/](docs/specs/) and [docs/specs/README.md](docs/specs/README.md) |
| Make a durable architectural choice | [docs/decisions/](docs/decisions/) (ADRs) |
| Understand the method | [docs/reference/README.md](docs/reference/README.md) |
| Spawn a subagent, pick a model, or notice the session has run long | [.claude/rules/context-economy.md](.claude/rules/context-economy.md) (auto-loads; this row is for humans) |

## How work happens: spec-driven, two phases

Priority order: **specification → acceptance criteria → tests → implementation.**

**Phase A, specify.** For any non-trivial change: read this file and the relevant ADRs, inspect existing code and tests, then create or update the spec in `docs/specs/`. Include goals, non-goals, assumptions, behaviour, acceptance criteria, testing, open questions. Surface conflicts and ambiguities. Do not invent requirements. **Stop before implementation** and wait for approval.

**Phase B, implement.** Re-read the approved spec and this file. Make the smallest change that satisfies it. No unrelated refactoring. Add or update tests that map to the acceptance criteria. Run targeted tests, then `./scripts/check.sh`. Compare the final diff against every acceptance criterion. Report: files changed, tests, results, deviations, remaining risks.

Trivial changes (typo, a token value, a one-line fix with an obvious test) skip Phase A but still run the check.

## Failure policy

A failing test is evidence, not automatically the truth. The approved spec is the primary behavioural reference.

- Read the full failure. State a root-cause hypothesis before changing code. Make one targeted change. Run the smallest relevant test.
- **After 3 failed targeted attempts: stop and diagnose.** Classify as implementation defect, test defect, specification defect, environment or tooling issue, dependency or version issue, or unclear requirement.
- Never delete, skip, disable or weaken a test to get green. Never raise a timeout without a root cause. Never suppress an exception to satisfy a test. Stop on oscillation.
- If a test contradicts the spec, investigate the mismatch. The fix may belong in the test or the spec.

## Context and model tiers

Context is a budget spent per turn: checkpoint at every task boundary into `docs/STATUS.md` or the spec, offer a fresh session with a paste-ready resume prompt, and read narrowly. Phase A is session work. Phase B delegates by tier: **Opus = judgment** (verification against acceptance criteria never runs below it), **Sonnet = volume** (implementing an approved spec, tests, file sweeps), **Haiku = clerical**. When the session runs Fable, Fable orchestrates and rules; it is never a subagent tier. A cheap tier may gather evidence; it may never rule on it. These lines survive compaction; the full rule is in [.claude/rules/context-economy.md](.claude/rules/context-economy.md).

## Non-negotiables

1. **Sovereign.** No prompt, completion, model file, or usage data leaves the machine. Network use is limited to catalogue queries and downloads (model files and the inference engine), and the app shows what it fetched, from where, and when.
2. **Disk-honest.** Every download is resumable, checksummed against the source, visible with its size and location, and deletable from inside the app. The app never hides gigabytes.
3. **Measured or labelled.** Every benchmark and hardware number states whether it was measured or estimated, on which hardware, with which model file and parameters. A number without provenance is not shown.
4. **Licence-aware.** Every model card shows the weights' licence and gating. The app never bypasses gating and never redistributes weights.
5. **Tokens only.** No raw colour, font or shadow values in components. Use the tokens in `src/app.css`. Both modes must work for every change.
6. **Accessible as built.** Real buttons, inputs, labels and tables. Click targets 44 px minimum. Text contrast 4.5:1 (3:1 at 24 px+). Keyboard reachable.
7. **Zero running cost.** Free tiers only. No paid service without an ADR.
8. **Identity.** The author is Leo Xeno. Commits use the GitHub noreply address. No other personal identifiers, employers, or locations enter the repo, the commits, or the issues. Hardware facts are allowed; account names, hostnames and paths under a user profile are not.
9. **All rights reserved.** Do not add licence headers that grant rights. Do not vendor code whose licence conflicts with closed distribution without an ADR. Third-party binaries the app downloads at run time (llama.cpp, model weights) keep their own licences and are never committed.
10. **Specs are feature-sized.** One capability per spec. Never one giant spec. Never `v2` or `final` filenames; Git versions files.

## Commands

Two clones of this repo exist by design (ADR-0001): a Windows clone where the Rust toolchain, `tauri dev` and the installer run, and a WSL clone for docs, scripts and the fast Linux checks.

```bash
./scripts/setup-dev.sh        # once per clone: git hooks, identity check, toolchain hints
npm run tauri dev             # Windows clone: native window with hot reload
npm test                      # vitest, once
cargo test --manifest-path src-tauri/Cargo.toml
./scripts/check.sh --fast     # symlink, privacy, spec index, lint, typecheck, tests, fmt, clippy; no bundle
./scripts/check.sh            # the canonical gate; adds the Tauri bundle on a Windows host
```

CI runs `./scripts/check.sh --fast` on Linux and the bundle on Windows. CI and the protected `main` branch are the enforcement layer; local hooks are only fast feedback.

## Completion report

Every implementation ends with this, in the reply and nowhere else:

```
Spec: docs/specs/NNN-name.md (status after this work)
Changed: list of files
Tests: what was added or changed, and the run result
Criteria: each acceptance criterion with met / not met
Deviations: anything that differs from the spec, and why
Risks: what is still uncertain
```
