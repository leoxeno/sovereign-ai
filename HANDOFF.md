# Handoff · Sovereign AI explorer

Written 2026-10-06 at the end of a Kerix session, from the owner's answers. This file is the only input the new session needs besides the Kerix files copied into `_from-kerix/`. Delete both once the real spec tree exists.

## What the owner wants

An app for every app they build from now on: a sovereign explorer for open-weight language models. Search and find models on Hugging Face (and maybe other sources later), download them for local use, run them, learn AI engineering by playing with the parameters and understanding what they mean, keep presets, and benchmark models: energy cost against output, and per category (text, code, tool use, browsing, auditing, images, audio, science). "Sovereign" means the weights are owned and run on the owner's own machines; no prompt, model, or telemetry leaves them. The Hugging Face network is used only for the catalogue and downloads.

Stages apply here as in Kerix: **worm → cocoon → butterfly.** Build the worm. Nothing beyond it is scheduled.

## Decisions the owner already made (2026-10-06)

| Question | Decision |
|---|---|
| Platform | Desktop app with **Tauri** (Rust backend, web UI). Windows first, since that is the owner's machine; macOS and Linux follow from the same code. |
| Engine | **Wrap llama.cpp directly** (GGUF models). No Ollama dependency. Text models first; vision and audio later through the same engine. |
| Worm scope (all four) | 1. Search and download from Hugging Face. 2. Run and chat with a downloaded model, with parameter explanations and saveable presets. 3. Hardware fit and recommendations. 4. Benchmarks, including energy. |
| Benchmark categories first | Text and reasoning; tool use and browsing (browsing against a controlled fixture, never the live web). Code, images, audio, science: later stages. |
| Send to another device | **Not in the worm.** One machine first. The owner's Tailscale Linux machines come with the cocoon. |
| Identity and licence | **Same as Kerix:** public repo under the `leoxeno` account, author Leo Xeno, GitHub noreply address in commits, all rights reserved, no other personal identifiers anywhere, English. |
| Method | Spec-driven development with LLMs, exactly as Kerix: the repository is the source of truth; specification → acceptance criteria → tests → implementation; two phases with owner approval between them; one canonical check script; model tiers (Fable orchestrates, Opus judges, Sonnet implements, Haiku clerical). |
| Where to work | A fresh session and a new repo. Never inside the Kerix session. |

## The owner's machine (detected 2026-10-06 from WSL2, confirm in the first spec)

- Windows 11 Pro, 32 GB RAM, Intel Core i7-12700H (14 cores), NVIDIA GeForce RTX 3070 Ti Laptop GPU with 8 GB VRAM, plus Intel Iris Xe integrated.
- `nvidia-smi` is present and reports power draw, so **GPU energy is measurable through NVML**. CPU package power on Windows is not freely readable; the worm estimates it from time and TDP and labels every estimated number as estimated.
- Development happens in WSL2 (Ubuntu, Node 20 via nvm, no Rust toolchain yet) but the app targets Windows, so the Rust toolchain and Tauri build must run on Windows or in WSL with Windows cross-build. Decide in the stack ADR with evidence; do not assume.
- The 8 GB VRAM line decides a lot: 7B to 8B models at 4-bit quantisation fit on the GPU; 13B needs CPU offload; anything larger runs slowly on CPU with 32 GB. The hardware-fit feature should say exactly this kind of thing.

## Non-negotiables to carry over and to add

From Kerix, unchanged in spirit: tokens only (no raw colour, font or shadow values in components; both themes work), accessible as built (real controls, 44 px targets, 4.5:1 contrast, keyboard reachable), zero running cost (no paid service without an ADR), identity, all rights reserved, specs feature-sized.

New for this product, to be written into its CLAUDE.md:
1. **Sovereign.** No prompt, completion, model file, or usage data leaves the machine. Network use is limited to catalogue queries and downloads, and the app shows what it fetched.
2. **Disk-honest.** Every download is resumable, checksummed against the source, visible with its size and location, and deletable from inside the app. The app never hides gigabytes.
3. **Measured or labelled.** Every benchmark number states whether it was measured or estimated, on which hardware, with which model file and parameters. A number without provenance is not shown.
4. **Licence-aware.** Every model card shows the weights' licence and gating; the app never bypasses gating and never redistributes weights.

## What to copy from Kerix, and how to adapt it

Everything is in `_from-kerix/`:
- `CLAUDE.md`: keep the structure (one rule, read-on-demand table, two phases, failure policy, tiers, non-negotiables, commands, completion report). Replace the product line, the non-negotiables (above), and the commands (Tauri and Rust commands join npm). `AGENTS.md` stays a symlink to it, checked by the check script.
- `.claude/rules/context-economy.md`: copy as is; the tier policy is shared across the owner's repos. Replace the last section ("Kerix routing") with this product's routing: Rust and Tauri work is Sonnet volume; anything touching energy measurement or benchmark scoring is Opus judgment, because being wrong is expensive there.
- `scripts/check.sh` and `scripts/setup-dev.sh`: keep the shape (symlink check, privacy scan, lint, typecheck, test, build) and add `cargo fmt --check`, `cargo clippy`, `cargo test`, and the Tauri build behind a `--fast` flag, since Rust builds are slow.
- `docs/specs/TEMPLATE.md` and `docs/specs/README.md`: copy; empty the index.
- `docs/reference/`: copy the guide and its README. ADR-0004 in Kerix adopts it; write the equivalent ADR here.
- `docs/decisions/0002-stack.md` and `0004-spec-driven-development.md`: examples of the ADR voice, not content to reuse.
- `docs/STATUS.example.md` and `ci.example.yml`: the pick-up page and the CI shape to imitate.

## Proposed first documents (Phase A, all for owner approval)

1. `docs/VISION.md`: one sentence, three stages (worm, cocoon, butterfly), who it is for (the owner, then anyone who wants to own their models), what it is not (not a cloud AI client, not a model host, not a chat product).
2. `docs/PRODUCT.md`: the worm scope above as numbered capabilities, the build order, and the stage rule.
3. `docs/decisions/0001-stack.md`: Tauri 2 with Rust, web UI (React or Svelte, decide with evidence against the Kerix choice), llama.cpp integration (bundled `llama-server` binary driven over localhost versus a Rust binding crate: compare build complexity, GPU builds, and update path), SQLite for the local catalogue and benchmark records.
4. `docs/decisions/0002-energy-measurement.md`: NVML for GPU power on NVIDIA; estimate for CPU on Windows; what "energy per answer" means (joules from start of prompt to end of generation, idle baseline subtracted).
5. `docs/decisions/0003-spec-driven-development.md`: adopt the guide.
6. A naming round like Kerix's `docs/design/NAMES.md`, unless the owner already has a name. "Sovereign AI chooser" is the owner's working phrase.

Then specs, one capability each, in this order: **001 Hardware report** (smallest useful thing, and it answers what fits), **002 Catalogue: search and download**, **003 Run and chat with presets and explanations**, **004 Benchmarks: text and reasoning**, **005 Benchmarks: tool use and browsing fixture**, **006 Energy per answer**.

## Open questions for the owner, to ask in Phase A

- Name of the project and the repo.
- Web UI framework: React like Kerix (one mental model across both apps) or something lighter.
- Hugging Face account: gated models (Llama, Gemma) need a token; where it lives and how the app asks for it.
- What "quality" means in the benchmarks: exact-match answer sets you write, or scoring by another local model.
- Whether the Kerix design tokens and voice carry over, or this app has its own look.

## Resume prompt for the new session

```
New project: sovereign AI explorer (working name). Start in /root/projects/leoxeno/sovereign-ai.
Read HANDOFF.md first; it holds every decision the owner has made and the hardware facts. The files under _from-kerix/ are the method to adapt, not content to copy blindly.
Phase A only: ask the open questions in HANDOFF.md, then create the repo skeleton (CLAUDE.md with AGENTS.md symlink, .claude/rules/context-economy.md, scripts/check.sh, docs tree with VISION, PRODUCT, STATUS, decisions, specs, reference) and draft ADR-0001 stack and spec 001 Hardware report. Stop for approval before any implementation.
Constraints: spec-driven two phases, one step at a time, stages worm → cocoon → butterfly, non-negotiables in HANDOFF.md, model tiers in _from-kerix/.claude/rules/context-economy.md (Fable orchestrates, Opus judges, Sonnet implements, Haiku clerical). Identity: Leo Xeno, GitHub noreply, all rights reserved, no other identifiers.
```
