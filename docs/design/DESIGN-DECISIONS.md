# Design decisions

Product: **Sovereign AI explorer** (working name). A desktop app for owning, running and measuring open-weight models.

Aesthetic brief from the owner (2026-10-06): *Civilization: Beyond Earth, Rising Tide*, the six affinity systems: **Purity**, **Supremacy**, **Harmony**, and their hybrids **Purity–Supremacy**, **Purity–Harmony**, **Supremacy–Harmony**. Six palettes are proposed as boards; the owner selects the way Kerix's look was selected, from artboards, one direction per board, tokens beside each.

## What carries over from Kerix

The method, not the look:

- **Token structure.** Named CSS custom properties on `:root`, dark mode under `prefers-color-scheme: dark` guarded by `:root:not([data-theme="light"])` and again under `:root[data-theme="dark"]`, exposed to Tailwind 4 with `@theme inline`. Components use tokens only (non-negotiable 5).
- **Two modes that share geometry and differ in physics.** Kerix separates layers with shadow in light and glow in dark; each affinity board states its own pair.
- **UX invariants.** Real controls, 44 px targets, 4.5:1 body contrast (3:1 at 24 px+), keyboard reachable. Numbers are set in a monospace face so columns align and provenance labels sit beside them.
- **Voice.** Short sentences. Labels say what a thing is, not what the user should feel.

## Invariants specific to this product

- **A number is never alone.** Every measured or estimated value has a provenance label in the same visual unit; the design must make the label legible without making the table noisy.
- **Disk and network are visible.** Sizes, locations and what was fetched are first-class content, not settings.
- **Learning mode is calm.** Parameter explanations sit beside the control, in the same type scale as captions, and never interrupt.

## Round 01 · Affinities

Artifact: https://claude.ai/artifact/AZGzvNbH9Wh3FGHQgE5nMi · sources in `boards/01-affinities/`. Six boards, each the Hardware report of spec 001 at 1280 px with a **Dark** tweak that switches the whole board between its two modes, and a token strip under the screen. Light mode lifts surfaces with shadow in every direction; dark mode lifts with a glow in the direction's own colour. Verdict chips (fits, partial offload, does not fit) use one semantic set per mode and differ in lightness, not hue alone.

| # | Direction | Type | Light | Dark | Idea |
|---|---|---|---|---|---|
| 1 | **Purity** | Cormorant Garamond · Source Sans 3 · JetBrains Mono | Marble sun: ivory `#F3EEE4`, amber `#E0962B`, amber text `#A4520C` | Ember hall: `#17130E`, amber glow `#F0A93B` | Humanity, kept. Warm stone and sun; the heritage reading of a tool that keeps your models at home. |
| 2 | **Supremacy** | Rajdhani · IBM Plex Sans · IBM Plex Mono | Chrome: steel-white `#ECEFF4`, cyan `#19B6E0`, cobalt text `#1F5FBF` | Void deck: `#090C12`, cyan glow `#35C0EE` | Beyond the body. Cold, exact, machine-first; the benchmark console reading. Opens dark. |
| 3 | **Harmony** | Fraunces · Figtree · DM Mono | Canopy: pale moss `#EEF3EA`, green `#6FD39A`, green text `#276A35` | Bioluminescent: `#0A120D`, green glow `#5FD88C`, violet `#B48CF0` | Grown with the planet. Organic serif, soft greens, xenomass violet as the second light. Opens dark. |
| 4 | **Purity–Supremacy** | Marcellus · Instrument Sans · Red Hat Mono | Bronze plate: `#F0EDE8`, bronze `#C8903C`, steel text `#2B5C9E` | Steel vault: `#121214`, bronze `#E39B4E`, steel glow `#6FA7F0` | Armoured humanity. Bronze marks the place, steel does the work: warm nav, cold controls. |
| 5 | **Purity–Harmony** | Lora · Karla · Source Code Pro | Greenhouse noon: straw `#F4F1E3`, olive `#9AB53C`, honey text `#8A5114` | Orchard night: `#15170E`, olive `#B9D04A`, honey `#E6B74A` | A terraformed garden. The gentlest of the six; reads as a notebook more than a console. |
| 6 | **Supremacy–Harmony** | Exo 2 · Atkinson Hyperlegible · JetBrains Mono | Tidal lab: `#E9F1F2`, teal `#22D3C5`, violet text `#6B47C4` | Abyssal reef: `#081216`, teal `#35E0D0`, violet `#A98BFF` | Bio-synthetic deep. Teal and violet nanolight; the most legible body face of the set. Opens dark. |

Every text-on-ground pair in the strips is at or above 4.5:1 by calculation; the implementing spec re-checks the real tokens with a contrast tool before they enter `src/app.css`.

Decision: pending. Recorded here as ADR-001 (design) when the owner picks a direction, with the chosen tokens and any borrowed element from the others, as Kerix did.
