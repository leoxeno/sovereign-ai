# Sovereign AI explorer

**Own the models you use.** Find open-weight language models, download them, run them on your own machine, learn what the parameters mean, and know what every answer costs.

Sovereign means the weights live and run on your hardware. No prompt, model, or usage data leaves the machine; the network is used only to search the catalogue and download files, and the app shows what it fetched.

Working name. Built in public by [Leo Xeno](https://github.com/leoxeno). All rights reserved.

## Status

Phase A: the spec tree exists; nothing is implemented yet. The pick-up page is [docs/STATUS.md](docs/STATUS.md); scope and build order are in [docs/PRODUCT.md](docs/PRODUCT.md); the first spec is [docs/specs/001-hardware-report.md](docs/specs/001-hardware-report.md).

## How it is built

Tauri 2 with a Rust backend, a Svelte 5 UI, llama.cpp as the engine, SQLite for records ([ADR-0001](docs/decisions/0001-stack.md)). Spec-driven, two phases, one canonical check script ([ADR-0003](docs/decisions/0003-spec-driven-development.md)). Agent rules are in [CLAUDE.md](CLAUDE.md).
