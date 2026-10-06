# Reference

## Spec-Driven Development with LLMs · Quick Guide

`Spec-Driven-Development-with-LLMs-Quick-Guide.pdf`, by Ioannis Panteleakis. Included with the author's knowledge as the method this app is built with, as it is in Kerix. ADR-0003 adopts it.

The parts applied directly:

- **The repository is the source of truth, not the chat.** Section 1.
- **Priority order:** specification → acceptance criteria → tests → implementation. Section 1.
- **Structure:** `CLAUDE.md` for stable rules, `docs/specs/` for feature requirements, `docs/decisions/` for ADRs, thin git hooks and one canonical check script. Sections 2 and 9. (The guide's `docs/architecture/` folder appears here when the first spec that crosses the Rust and UI boundary needs it, expected with spec 002.)
- **Spec lifecycle and when to update vs create.** Sections 3 and 7.
- **Spec sections.** Section 4, mirrored in `docs/specs/TEMPLATE.md`.
- **Two-phase prompting:** specify and stop; then implement exactly. Section 6.
- **Failure policy:** three targeted attempts, then stop and classify; never weaken tests to get green. Section 8.
- **Anti-patterns:** one giant spec, chat as the only requirement source, silent resolution of ambiguity, `v2/final` files, unbounded retries, local hooks as policy. Section 10.

The guide's example is a Python floor-plan tool with GitLab CI; this app maps `uv run ruff` and friends to `npm run lint`, `cargo clippy` and friends, and GitLab CI to GitHub Actions. The method is unchanged.
