# ADR-0003 · Spec-driven development with an agent

**Status:** Proposed · 2026-10-06

## Decision

This app is built spec-first by an AI agent with the owner approving. The method follows the guide in [../reference/](../reference/README.md): the repository is the source of truth; specification precedes acceptance criteria, tests and implementation; work runs in two phases (specify and stop, then implement exactly); failures get three targeted attempts, then a stop and a classification; one canonical check script is run by hooks and by CI, and CI is the enforcement layer.

The agent-facing rules live in `CLAUDE.md`, with `AGENTS.md` a symlink so any agent tool reads the same file. The tree of linked documents under `docs/` holds everything that changes more often than the rules. Model tiers (Fable orchestrates, Opus judges, Sonnet implements, Haiku clerical) are in `.claude/rules/context-economy.md`, shared with the owner's other repos.

## Why

The owner's working style is to approve, not to type. That only works if what is being approved is written down, small, and testable. A chat transcript is not reviewable; a spec with acceptance criteria and a diff against it is. Specs also survive context resets and model changes, which conversations do not.

This product adds a reason of its own: its numbers are the product. A benchmark result or an energy figure that cannot be traced to a spec, a model file and a measured or estimated label is worthless, and the method that makes code reviewable is the same one that makes numbers trustworthy.

## Consequences

- Every feature has a numbered spec in `docs/specs/` with a status line. Refinements update the same spec; new capabilities get a new spec.
- Durable choices become ADRs here. Feature details do not.
- `scripts/check.sh` is the only definition of "green". Rust builds are slow, so `--fast` skips the bundle for hooks; the full script stays the gate, and the bundle builds on a Windows host.
- The agent reports completion in a fixed format so the owner can approve from the report and the diff alone.
- Two clones (Windows for builds, WSL for docs and Linux checks) run the same script; the script skips what a host cannot do and says so.
