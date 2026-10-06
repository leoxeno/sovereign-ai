# Status

Updated 2026-10-06. The one page to read when picking this project up cold. Keep it short; history lives in git and the specs.

## Where we are

| Item | Status | Note |
|---|---|---|
| Repo skeleton | Drafted | CLAUDE.md, rules, scripts, hooks, CI, docs tree. Not yet committed; awaiting owner approval of Phase A. |
| ADR-0001 Stack | Proposed | Tauri 2 + Svelte 5, llama-server sidecar, rusqlite, two clones. Awaiting approval. |
| ADR-0003 Spec-driven development | Proposed | Adopts the guide in docs/reference. |
| Spec 001 Hardware report | Draft | Awaiting approval; open questions listed in the spec. |
| Design round 01 Affinities | Boards published | Six directions, light and dark each, in docs/design/DESIGN-DECISIONS.md; owner picks. |
| Name | Deferred | Working name stays. Candidates in docs/design/NAMES.md. |

Stage: **worm.** Build order and the four capabilities are in [PRODUCT.md](PRODUCT.md).

## Next action

**Paused by the owner on 2026-10-06 with Phase A drafted and pushed, nothing approved yet.** On return, in this order: (1) owner approves or amends ADR-0001, ADR-0003 and spec 001 (four open questions in the spec), and picks a direction from design round 01; (2) delete `HANDOFF.md` and `_from-kerix/` (their content now lives in the tree), record the chosen direction in `docs/design/DESIGN-DECISIONS.md`, protect `main`; (3) ADR-0002 Energy measurement is written (NVML cumulative energy counter, idle baseline, what "energy per answer" means), then spec 002 Catalogue; (4) Phase B of spec 001 on the Windows clone: install rustup, `create-tauri-app` with the Svelte template, then the hardware report against the acceptance criteria.

Resume prompt for the next session:

```
Continue the Sovereign AI explorer (working name) in /root/projects/leoxeno/sovereign-ai.
Read CLAUDE.md, then docs/STATUS.md for where we are and the next action. Phase A is drafted and pushed; nothing is approved yet.
First: collect my approvals or amendments on docs/decisions/0001-stack.md, docs/decisions/0003-spec-driven-development.md and docs/specs/001-hardware-report.md (answer its four open questions), and my pick from design round 01 (docs/design/DESIGN-DECISIONS.md, artifact link there). Then do step 2 of the next action, then draft ADR-0002 energy measurement. Stop before any implementation.
Constraints: spec-driven two phases, one step at a time, worm stage only, non-negotiables in CLAUDE.md, tiers in .claude/rules/context-economy.md. Identity: Leo Xeno, GitHub noreply, all rights reserved.
```

## Environment notes for the agent

- **Two clones.** The WSL clone (this one) holds docs, scripts, and the fast Linux checks. The Windows clone, on the Windows filesystem (not under `/mnt/c` from WSL, not under `\\wsl$` from Windows), runs rustup, `tauri dev` and the installer. Git syncs them; `.gitattributes` forces LF.
- **Windows side, confirmed 2026-10-06:** Windows 11 Pro (build 26200), Visual Studio Build Tools 2026 with the C++ workload, WebView2 runtime, CMake, the CUDA compiler, Node. **Missing:** rustup. Install with the MSVC host toolchain before Phase B of spec 001.
- **WSL side:** Ubuntu, Node 20.20 via nvm, no cargo, no cmake. Clippy on this clone needs rustup plus Tauri's Linux link packages (`scripts/setup-dev.sh` prints the lines). Until then the Rust steps run on the Windows clone only.
- **Hardware, confirmed 2026-10-06 from WSL and PowerShell:** i7-12700H (14 cores, 20 threads), 31.7 GiB RAM (WSL itself sees 23 GiB, its default allocation), RTX 3070 Ti Laptop GPU 8192 MiB (NVML/nvidia-smi; WMI reports 4095 MB because of a 32-bit field, never use it), Intel Iris Xe integrated, NVIDIA driver 616.92, `nvidia-smi` reports live power draw (20 W idle at the time) and no power limit. System drive about 1 TB with about 350 GB free.
- **Git identity.** The global git email is not a noreply address; set `user.name` and `user.email` per clone before the first commit (`scripts/setup-dev.sh` warns). The privacy scan in `scripts/check.sh` fails on consumer mail domains and user-profile paths.
- Secrets: none yet. The Hugging Face token, when spec 002 adds it, goes in the OS credential store, never in a file in the tree.

## Open risks

- `llama-server` power readings on the laptop GPU: NVML reports power on this machine through nvidia-smi, but `total_energy_consumption` (the cumulative counter ADR-0002 will prefer) is unverified until a Rust probe runs on the Windows clone.
- Tauri sidecar plus CUDA DLLs: the docs are silent on shipping DLLs next to a sidecar, and a known issue (tauri-apps/tauri#15134) affects sidecar replacement on reinstall. ADR-0001 sidesteps the installer by downloading the engine at first run, but the DLL layout still needs a spike in spec 003.
- Svelte is a second UI mental model next to Kerix's React. Tooling (Vite, Tailwind 4, Vitest, oxlint) transfers; component idioms do not.
- The guide PDF is included with its author's knowledge, as in Kerix; the reference README records this.
