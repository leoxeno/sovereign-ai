# Spec 001 · Hardware report

**Status:** Draft · **Stage:** worm · **Owner approval:** pending

## Summary
The app's first screen reports what this machine is and what size of model fits on it. Every number says whether it was measured or estimated and from which source.

## Problem
The owner's machine has 8 GB of VRAM and 32 GB of RAM. Whether a model runs well, slowly, or not at all is decided by those two numbers against the model file's size and the context length, and nobody should have to work that out by hand. The report is also the smallest useful thing the app can do: it exercises the Rust side (probing hardware), the UI side (tokens, tables, both modes) and the "measured or labelled" rule before any model is downloaded. Later specs reuse its fit function (002 shows fit per file in the catalogue; 004 to 007 store its snapshot with every benchmark record).

## Goals
- Show the machine: CPU name, physical cores and logical threads; total and available RAM; every GPU with vendor, name, dedicated VRAM, whether it is integrated, and for NVIDIA the driver version, free VRAM and whether power and energy can be read; free space on the drive that holds the models folder, with the folder's path.
- Say whether energy is measurable on this machine, and how (NVML), or that it is not and estimates will be used.
- For a table of reference model classes, and for any (file size, context length, architecture dimensions) the caller passes in, give one of four verdicts with the numbers behind it: **fits on the GPU**, **partial CPU offload**, **CPU only**, **does not fit**.
- Label every value measured or estimated, with its source.
- Refresh on demand, with the time of the last reading.

## Non-goals
- Downloading, running or listing models (002, 003).
- CPU package power, Intel integrated GPU power, AMD GPU power: not readable on Windows without a kernel driver and administrator rights. The report says "not measurable" for these; ADR-0002 decides the estimate.
- Changing the models folder (002).
- Benchmarking the machine (004 onward). This spec reads static facts and live free-memory counters; it runs nothing.
- macOS and Linux probes. The Rust probe is behind a trait so they can be added; only the Windows implementation and a fake are in scope.

## Inputs / outputs
- **Inputs:** none from the user except Refresh. Internally: `sysinfo` for CPU and RAM; DXGI adapter enumeration for every GPU's name, vendor and dedicated VRAM; `nvml-wrapper` for NVIDIA driver version, total and free VRAM, and the availability of power and cumulative-energy readings; the filesystem for free space at the models folder; a table of reference model classes kept in the Rust crate.
- **Outputs:** one `HardwareReport` value from a Tauri command, rendered as the Hardware screen; the same value serialised to JSON for tests and later for benchmark records. The fit function `fit(need_bytes) → Verdict` and `need(file_bytes, ctx, dims) → bytes` are public in the Rust crate.
- **Network:** none. The capability file for this screen grants no HTTP permission; the Rust side makes no requests.

## Assumptions
- Windows 11 with a working graphics driver. If NVML is absent (no NVIDIA driver), the report still renders; the NVIDIA rows read "not available".
- WMI's `AdapterRAM` is never used for VRAM: it is a 32-bit field and reports 4095 MB for the owner's 8 GB card. DXGI and NVML are the sources.
- Memory need for a model is estimated as `file size + KV cache + overhead`, where KV cache is `2 × layers × kv_heads × head_dim × ctx × bytes_per_element` (2 bytes for f16) and overhead is a constant 0.75 GiB for compute buffers and the CUDA context. Usable VRAM is `total VRAM − 1 GiB` reserved for the desktop. These three constants live in one place, are labelled estimated in the UI, and are expected to be tuned once spec 003 measures real loads.
- Verdict rules, in order: **fits on the GPU** if need ≤ usable VRAM; **partial CPU offload** if need > usable VRAM and file size ≤ available RAM; **CPU only** if there is no usable GPU and file size ≤ available RAM; **does not fit** if file size > available RAM. Integrated GPUs that share system memory count as no usable GPU for this rule.
- The reference table, with f16 KV at 8k context and Llama-3-class dimensions unless stated: 7B/8B at Q4_K_M (about 4.6 GiB file), 8B at Q8_0 (about 8.0 GiB), 13B at Q4_K_M (about 8.0 GiB), 30B-class at Q4_K_M (about 18 GiB), 70B at Q4_K_M (about 40 GiB). The sizes are estimates and are labelled as such; spec 002 replaces them with real file sizes from the Hub.
- Design tokens exist in `src/app.css` with both modes before this screen is built (design round 01 picks the palette; until then the Kerix token names with a placeholder palette are acceptable for implementation and are swapped by a token-only change).

## Behaviour
1. The app opens on the Hardware screen (it is the only screen in this spec).
2. The UI calls the `hardware_report` command. While it runs (under two seconds expected), the screen shows a labelled loading state, not an empty table.
3. The report renders as three sections: **This machine** (CPU, RAM, disk), **Graphics** (one row per GPU, NVIDIA rows with driver, free VRAM and "Energy: measurable through NVML" or "Energy: not measurable on this GPU"), **What fits** (the reference table with a verdict and the numbers per row: file, KV cache, overhead, need, usable VRAM).
4. Every number carries a small provenance label: `measured · NVML`, `measured · DXGI`, `measured · sysinfo`, `estimated · formula`. Hovering or focusing the label shows the one-sentence explanation (what the source is, why it is an estimate).
5. A **Refresh** button re-runs the command and updates the "read at HH:MM:SS" line. Free VRAM, available RAM and free disk are the values expected to change.
6. If any probe fails, that section shows the failure in words ("NVIDIA driver not found; VRAM from DXGI only") and the rest of the report still renders. A probe failure never blanks the screen.

## Acceptance criteria
1. **Given** the owner's machine, **when** the Hardware screen loads, **then** it shows CPU "12th Gen Intel(R) Core(TM) i7-12700H", 14 cores and 20 threads, total RAM between 31 and 32 GiB, each labelled `measured · sysinfo`.
2. **Given** the owner's machine, **when** the Graphics section renders, **then** the NVIDIA row shows "NVIDIA GeForce RTX 3070 Ti Laptop GPU", total VRAM 8192 MiB labelled `measured · NVML`, a free-VRAM value below the total, the driver version, and "Energy: measurable through NVML"; and the Intel Iris Xe row is shown as integrated and excluded from fit.
3. **Given** a fake probe with no NVML, **when** the report renders, **then** GPUs still list name and VRAM from DXGI, the energy line reads "Energy: not measurable on this GPU; estimates only", no error is thrown, and the What-fits table uses the DXGI VRAM total.
4. **Given** the fit function with an 8B model at Q4_K_M (4.6 GiB file), 32 layers, 8 KV heads, head dimension 128, 8192 context, f16 KV, **when** need is computed, **then** the KV cache is 1.0 GiB, the need is about 6.35 GiB, and against 8 GiB total VRAM the verdict is **fits on the GPU**.
5. **Given** the same dimensions with a 13B Q4_K_M file of 8.0 GiB and 32 GiB RAM, **then** the verdict is **partial CPU offload**; with a 70B Q4_K_M file of 40 GiB **then** the verdict is **does not fit**; with no usable GPU and the 8B file **then** the verdict is **CPU only**.
6. **Given** any rendered number, **when** the user inspects its label, **then** the label says measured or estimated and names the source, and no number appears without one (a test walks the rendered report and asserts every numeric cell has a sibling provenance label).
7. **Given** the Hardware screen, **when** navigated by keyboard only, **then** Refresh and every provenance label are reachable and operable, Refresh is at least 44 × 44 px, and text contrast is at least 4.5:1 in both modes.
8. **Given** the Hardware screen's capability file, **then** it grants no `http`, `shell` or `fs` permission beyond what the command needs, and the Rust command opens no socket (asserted by a test that runs the probe with networking denied, or by review if a test is not feasible; the review is recorded in the completion report).
9. **Given** Refresh is clicked, **then** the "read at" time updates and the command is re-run (a test with the fake probe counts calls).
10. **Given** a run on the owner's machine, **then** the full report is pasted into this spec's revision history as the first real reading, with every value and label, and the owner confirms it matches the machine.

## Testing
- Rust unit tests in `src-tauri/src/hardware/` for `need()` and `fit()` with the fixture table from criteria 4 and 5, plus the constants' boundaries (need exactly equal to usable VRAM fits).
- A `HardwareProbe` trait with a Windows implementation and a `FakeProbe`; the report assembly is tested against the fake with and without NVML (criterion 3).
- Svelte component tests with Vitest and Testing Library: loading state, three sections, provenance labels on every number (criterion 6), Refresh re-invokes (criterion 9), keyboard reachability (criterion 7).
- A manual acceptance run on the owner's Windows clone for criteria 1, 2 and 10, recorded in the revision history.
- `./scripts/check.sh` green on both clones (the bundle on Windows).

## Open questions
- Should the report include the power source (AC or battery) and the active Windows power plan? Both change benchmark results on a laptop; cheap to read, and criterion 10 would then record them. Proposed: yes, as a fourth line under This machine, labelled measured.
- Should the thread recommendation for llama.cpp (performance cores only, 6 on this CPU) appear here or wait for spec 003? Proposed: 003, where it can be measured.
- Does the report persist to SQLite now, or only when 004 needs a snapshot per benchmark record? Proposed: 004; this spec keeps the value in memory and returns it on demand.
- The 1 GiB desktop reserve and 0.75 GiB overhead are guesses from community figures. Accept them as labelled estimates until 003 measures real loads?

## Revision history
### 2026-10-06
Created from the handoff and the hardware facts confirmed from WSL and PowerShell on the same day. Reason: first spec of the worm. Impact on completed work: none.
