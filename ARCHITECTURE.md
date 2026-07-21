# Architecture

## Overview

688 Attack Hub is one self-contained HTML file: `688-attack-hub.html`. Inline
`<style>` holds the CSS, inline `<script>` holds every line of game logic, and
an inline `<svg>` renders the world map. There is no build step, no bundler,
and no external asset — everything the browser needs is in that one file.

## Directory structure

```
.
├── 688-attack-hub.html   # the entire game: HTML + CSS + JS + SVG map, inline
├── .github/workflows/    # ci.yml (integrity checks), pages.yml (deploy)
├── .machine_readable/    # agent-facing metadata (descriptiles + contractiles)
├── .well-known/          # ai.txt, humans.txt, security.txt
├── LICENSE               # AGPL-3.0-or-later
├── LICENSES/             # full text of every licence referenced in this tree
└── (the documentation set linked from README.md)
```

There is no `src/`, no `tests/`, no build tooling. Unlike this repo's sibling
`f19-stealth-glider` (which has a verification ledger of `src/verify*.mjs`
scripts backing formal geometric claims), 688 Attack Hub makes no such claims
— it's an idle/strategy toy, not a puzzle with a provable solution. See
[`AUDIT.adoc`](./AUDIT.adoc) for what is and isn't asserted about it.

## Data model (inside `688-attack-hub.html`)

- **`REGIONS`** — 20 internet exchange points, each with a real IX name
  (LINX, DE-CIX, AMS-IX, MSK-IX, Equinix SG, HKIX, ...) and its actual
  longitude/latitude, plus a port-capacity value (`cap`).
- **`EDGES`** — the backbone routes connecting regions (e.g. `sea↔sjc`,
  `lhr↔ams`), used both for the visual links and for adjacency (`adj`) that
  gates which regions can be reached from an installed one.
- **`LAND`** — hand-traced coastline polygons, projected with `PX`/`PY`
  (equirectangular) and rendered as the SVG world map background.
- **`UPGRADES`** — 18 entries across four trees: `Physical` (cabling/optics —
  cost and link-cost effects), `Timing` (repeater-hop budget), `Stealth`
  (attention-gain reduction), `Spread` (leak rate into neighbouring segments).
- **`CMS`** (countermeasures) — six attention thresholds (20/35/50/65/80/100%),
  each firing a syslog-style message; 100% is the loss condition
  ("THE GREAT DESWITCHING").
- **`S`** (state) — the live game state: phase, tick, throughput (`gbps`),
  port points (`pp`/`spent`), attention (`att`), installed regions, and active
  links (`S.links`).

## Render / update loop

`step()` runs on a `setInterval` timer (`start()`/`stop()`, speed-adjustable)
and advances `S` by one tick: income, attention gain, countermeasure checks,
and the passive "Spread" leak mechanic. `paintMap()` re-renders the SVG map
and link lines; `paintUps()`/`paintUps2()` re-render the upgrade shop; `log()`
appends to the on-screen ticker. `click(id)` and `buy(u)` are the two player
input paths — install/link a region, or purchase an upgrade. `over(win)`
ends the run (loss at 100% attention; no explicit win condition beyond
"keep going").

## Roadmap (not implemented — ideas only)

Two different directions have been discussed for "the next generation" of
this game; neither has started, and they are not the same kind of change:

- **3D globe view (Globe.gl).** Replace the flat-projection SVG map with a
  rotating 3D globe showing nodes/arcs, visually similar to Hurricane
  Electric's [3D network map](https://www.he.net/3d-map/) (which is HE's own
  proprietary in-house tool — no public library or API behind it, confirmed
  by inspection; nothing to depend on directly). [Globe.gl](https://github.com/vasturiano/globe.gl)
  (a Three.js wrapper, MIT-licensed) is the closest open equivalent and could
  be dropped in via a CDN `<script>` tag without breaking the "one
  self-contained file, no build" property this repo currently has.
- **Engine migration (Bevy/Fyrox).** A much bigger change: moving off the
  browser-canvas architecture entirely onto a Rust game engine with a
  Cargo→WASM build pipeline and a different (ECS-based) architecture. This
  would be the right call only if the game grows into an actual 3D/simulation
  title rather than staying a browser idle-toy — it is a rewrite, not an
  upgrade, and would give up the current zero-install property.

Neither direction is committed. Whichever is chosen, update this section and
`CHANGELOG.md` before starting.
