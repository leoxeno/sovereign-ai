# Product

Working name: Sovereign AI explorer (the owner's phrase: "Sovereign AI chooser"). A name round is in [design/NAMES.md](design/NAMES.md); the decision is deferred.

## Stage rule

Stages are **worm → cocoon → butterfly** ([VISION.md](VISION.md)). Build the worm. Nothing beyond it is scheduled. A capability that belongs to a later stage is written down in VISION or an issue, never half-built in the worm.

## Worm scope: four capabilities

1. **Hardware report and fit.** What this machine is (CPU, RAM, GPUs and VRAM, driver, free disk, whether energy is measurable) and, for a given model file and context length, one of: fits on the GPU, needs partial CPU offload, CPU only, does not fit. Every number labelled measured or estimated with its source.
2. **Catalogue: search and download.** Search Hugging Face for GGUF models; show licence, gating, parameter count, architecture, context length and file sizes per quantisation; download with resume and a sha256 check against the Hub's own hash; list, locate and delete what is on disk. Gated models need the user to accept terms on the website and provide a read-only token; the app keeps that token in the OS credential store, and may use `HF_TOKEN` or the official CLI's token file only after asking.
3. **Run and chat with presets and explanations.** Load a downloaded model through llama.cpp, chat with it, and change every parameter (sampling, context, GPU layers, threads) with a plain-language explanation of what it does and what it costs. Save and recall presets. Timings per answer are shown as measured.
4. **Benchmarks per category with energy.** Run a model against fixture sets and record quality, speed and energy per answer. Quality is scored two ways from the start: exact match against answer sets kept in the repo, and a rubric verdict from a second local model acting as judge; every score says which. Categories in the worm: text and reasoning; tool use and browsing against a controlled fixture, never the live web. Energy is measured on NVIDIA GPUs through NVML and estimated elsewhere; estimated numbers say so.

## Build order (one spec per capability, in this order)

| # | Spec | Capability | Status |
|---|---|---|---|
| 001 | Hardware report | 1 | Draft |
| 002 | Catalogue: search and download | 2 | planned |
| 003 | Run and chat with presets and explanations | 3 | planned |
| 004 | Benchmarks: text and reasoning, exact match | 4 | planned |
| 005 | Benchmarks: judge scoring by a local model | 4 | planned |
| 006 | Benchmarks: tool use and browsing fixture | 4 | planned |
| 007 | Energy per answer | 4 | planned |

Spec 005 was inserted on 2026-10-06 when the owner decided that exact-match and judge scoring both belong in the worm; the rest of the order is the handoff's.

## Decisions on record (2026-10-06)

- Platform: Tauri 2, Rust backend, Svelte 5 UI, Windows first; macOS and Linux from the same code later. [ADR-0001](decisions/0001-stack.md).
- Engine: llama.cpp wrapped directly (GGUF). No Ollama. Text models first; vision and audio later through the same engine.
- Send to another device: not in the worm.
- Energy: GPU through NVML where available; CPU estimated from time and TDP and labelled as such. ADR-0002, next.
- Look: a palette round based on the six affinity systems of Civilization: Beyond Earth, Rising Tide (Purity, Supremacy, Harmony and their three hybrids), chosen from boards the way Kerix was. [design/DESIGN-DECISIONS.md](design/DESIGN-DECISIONS.md).
- Later stages, written down so they are not built now: other machines (cocoon); code, image, audio and science benchmark categories, other model sources, vision and audio models (butterfly).
