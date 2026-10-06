# ADR-0001 · Stack

**Status:** Proposed · 2026-10-06

## Decision

A Tauri 2 desktop app: Rust backend, Svelte 5 UI, Windows first, macOS and Linux later from the same code.

| Layer | Choice | Pinned to |
|---|---|---|
| Shell | Tauri 2 (the 2.x line; 3.0 alphas are not used) | 2.12.x at writing |
| Rust | stable, MSVC host toolchain on Windows | rustup stable |
| UI | Svelte 5 + TypeScript + Vite + Tailwind 4 | `create-tauri-app` Svelte template |
| UI checks | oxlint (lint), svelte-check (types), Vitest + Testing Library (tests) | |
| Engine | llama.cpp's `llama-server`, run as a supervised child process, driven over HTTP on 127.0.0.1 | an explicit `bNNNN` release tag and its sha256, recorded in the repo |
| Engine delivery | downloaded at first run from the pinned GitHub release, checksummed, listed with the models; not bundled in the installer | CUDA 12.4 build plus the cudart DLL zip for NVIDIA; Vulkan build as the fallback for every other GPU; CPU build as the last resort |
| Records | SQLite through `rusqlite` (bundled) and `rusqlite_migration`, owned by the Rust backend behind typed commands; no SQL in the webview | |
| Data locations | database in the app's local data directory (`%LOCALAPPDATA%`, never Roaming); model files in a user-chosen folder, default `<local data>/models` | |
| Hub access | plain `reqwest` with HTTP Range for downloads; sha256 from the Hub's `paths-info` endpoint; the OpenAPI spec at `huggingface.co/.well-known/openapi.json` is the contract | |
| Hardware | `sysinfo` (CPU, RAM), DXGI through the `windows` crate (every GPU's name and VRAM), `nvml-wrapper` (NVIDIA VRAM, utilisation, power, cumulative energy) | |
| Where it builds | two clones: a Windows clone on the Windows filesystem for rustup, `tauri dev` and the installer; a WSL clone for docs, scripts and the fast Linux checks | |
| CI | GitHub Actions: `ubuntu-latest` runs `check.sh --fast`; `windows-latest` builds the NSIS installer | |

## Why

- **Tauri over Electron.** Rust backend for the process supervision, hashing and NVML calls the app lives on, a system WebView instead of a bundled Chromium, and a capability system that lets the UI reach only the commands it is granted. The sovereign promise is enforced in Rust: every network call goes through a few audited commands, the webview gets no HTTP or shell permission of its own, and the content security policy allows only `'self'`.
- **Native Windows build, not WSL cross-build.** Tauri's own docs call cross-compiling Windows installers from Linux a caveated, NSIS-only path with no signing; `tauri dev` cannot open a WebView2 window from Linux at all. The owner's machine already has the Visual Studio Build Tools C++ workload, WebView2, CMake and the CUDA compiler. Only rustup is missing. Cargo and Vite are slow across the WSL and Windows filesystem boundary in either direction, so the clones stay on their own filesystems and Git carries the changes.
- **Svelte 5, the owner's choice** (2026-10-06), over React as in Kerix. The evidence is even: both are official Tauri templates, both render a token stream at 20 to 60 tokens per second without trouble (the real cost is re-parsing Markdown per token, in any framework). Svelte brings fine-grained updates without manual batching and compile-time accessibility warnings; React brings the larger accessible-component ecosystem and one mental model with Kerix. The owner weighed the second mental model as acceptable. Vite, Tailwind 4, Vitest and oxlint transfer unchanged; `svelte-check` replaces `tsc -b`.
- **`llama-server` as a sidecar over a Rust binding crate.** The maintained crate, `llama-cpp-2`, compiles llama.cpp from source: CMake, libclang, a C++ toolchain, and the CUDA toolkit on every build machine, with an API that its own README says does not follow semver. The server binary is prebuilt by the llama.cpp project many times a day for Windows with CUDA, Vulkan and CPU backends; an update is a new pinned tag and hash. A model crash kills the child, not the app. The server returns per-request timings (prompt tokens and milliseconds, generated tokens and milliseconds) that match what `llama-bench` reports, which is what the benchmarks need. The child is supervised through a Windows Job Object with kill-on-close so it never outlives the app, bound to a free port on 127.0.0.1, and polled on `/health`. One model per process; switching restarts the child. The server's newer router mode is a later evaluation.
- **Engine downloaded at first run, not bundled.** The CUDA build and its runtime DLLs are roughly 650 MB; bundling them would make a 700 MB installer that must be re-shipped at every engine update. Downloading from the pinned release makes the engine a disk-honest item like a model: shown, checksummed, deletable, updatable from inside the app. The installer stays small and the sidecar reinstall issue in Tauri (#15134) does not apply. The cost is one more network endpoint (GitHub releases), which the Sovereign rule allows as a download and the app shows.
- **`rusqlite` over `tauri-plugin-sql`.** The plugin runs SQL from the webview over IPC; the schema and every query would live in the UI. A backend that owns its schema behind typed commands is easier to test, to migrate and to keep out of the webview's reach. Bundled SQLite removes the system-library dependency. `sqlx` is heavier than a single-user local store needs.
- **Plain HTTP for the Hub.** The official `hf-hub` crate reached 1.0 in 2026 but its resume and progress behaviour could not be confirmed. The non-negotiables need our own `.part` files, hash-on-resume and progress events, which `reqwest` with Range gives directly. The Hub's `resolve` URL redirects to a signed CDN URL that serves byte ranges; the sha256 is known before download from `paths-info` and equals the `X-Linked-Etag` header, so "checksummed against the source" is a stream hash and a comparison.
- **Local data, not Roaming.** Benchmark records are machine-specific and model files are gigabytes; neither belongs in a profile Windows may sync.

## Alternatives considered

- **Ollama** as the engine: easiest start, but a second product with its own catalogue, model format and daemon, which hides the parameters this app exists to teach. Rejected by the owner before this ADR.
- **`llama-cpp-2` in-process:** exact per-call timing and in-process memory counters, at the cost above. Kept as a possible second backend behind the same engine interface if in-process control is ever needed.
- **Bundling the engine in the installer:** simplest first run, 700 MB installer. Rejected, see above.
- **React 19 (as Kerix):** see the Svelte bullet; the owner chose Svelte.
- **Cross-building from WSL2 with `cargo-xwin` and NSIS:** experimental, unsigned, no dev window. Rejected.
- **`tauri-plugin-sql`, `sqlx`:** see above.

## Consequences

- Phase B of spec 001 starts with `create-tauri-app` (Svelte, TypeScript) on the Windows clone after installing rustup. The scaffold is committed as its own change before any feature code.
- The engine interface in Rust is a trait from the first spec that runs a model (003), so a second backend never needs a rewrite.
- `scripts/check.sh` runs `cargo fmt --check`, `cargo clippy -D warnings` and `cargo test` wherever cargo exists and builds the bundle only on a Windows host; the WSL clone needs rustup plus Tauri's Linux link packages before it can run clippy.
- ADR-0002 (energy measurement) decides what the NVML counters mean; this ADR only decides that `nvml-wrapper` is how they are read.
- Every third-party binary the app downloads (engine, weights) keeps its own licence, is shown with it, and is never committed. `.gitignore` and the check script enforce the second half.
