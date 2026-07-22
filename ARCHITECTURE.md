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

## Projection: flat and globe

The map data was always spherical — `REGIONS` carry real longitude/latitude
and `LAND` is lon/lat polygons — so the flat plate-carrée projection was the
only thing standing between it and a globe. There are now two projections of
the same data, switched by the **FLAT / GLOBE** control in the footer. Flat
remains the default.

**`project(lon, lat)` is the seam.** It returns `{x, y, vis, z}`, and every
call site goes through it. Gameplay — `click()`, `buy()`, `step()`,
`canLink()`, `visLevel()` — never learns which projection is active. Only the
backdrop layer branches on mode, because a rectangular graticule and a sphere
have nothing in common; both layer groups are built once and toggled with
`display`.

**Geometry moved out of `buildMap()` into `positionMap()`.** `buildMap()`
originally created every SVG element once and `paintMap()` only ever mutated
appearance (fill, radius, opacity) — correct for a fixed map, useless for a
turning one. `paintMap()` still owns appearance; `positionMap()` owns
coordinates. Where the two overlap — a node's opacity depends both on what the
hub can overhear *and* on whether that node is currently on the far side of the
world — `paintMap()` records its decision and `applyVis()` combines the two.

**Rotation runs on `requestAnimationFrame`, not `step()`.** `step()` is the
game tick and is paused at 0× (see `start()`); a halted simulation should still
leave a live planet. `prefers-reduced-motion` suppresses the spin entirely
rather than merely slowing it.

**One `<path>` per edge, not one `<line>` per segment.** Each backbone run is
subdivided into `SEG = 24` pieces. As separate `<line>` elements that would be
31 edges × 24 segments × 2 layers × 4 coordinates ≈ 6,000 `setAttribute` calls
per frame; as a single `d` string it is 62. A path also solves horizon clipping
for free, because multiple `M` subpaths express gaps that a `<polyline>`
cannot. Measured in-browser: **0.34 ms** per geometry pass against a 16.7 ms
frame budget, across 181 SVG elements.

### Two traps, both of which look correct at a glance

- **Flat mode must interpolate along the shorter longitude delta.** Lerping raw
  longitudes sends Seattle→Tokyo (−122.3 → +139.7) the long way round, drawing
  the trans-Pacific cable straight across Eurasia — with both endpoints still
  in exactly the right place. `wrap180()` normalises the delta before
  subdividing, and the single sub-segment straddling ±180 is dropped. Globe
  mode slerps, which takes the shorter great circle for free.
- **An `opacity: 0` SVG element still hit-tests.** Without an explicit
  `pointer-events: none`, the far side of the planet stays clickable and you
  can select a city through the Earth.

### Known imperfection

**Coastlines at the limb.** A polygon straddling the horizon is cut at `z = 0`
and closed along the **chord** between its two crossings, not along the limb
arc. The seam is visible on close inspection at the edge of the disc. Fixing it
means walking the limb circle between crossings, which needs an unambiguous
winding direction; judged not worth the complexity for an MVP.

## Reaching the far side

`prefers-reduced-motion: reduce` suppresses the spin entirely, which is the
correct response to that media query — but on its own it strands the user with
a planet frozen at 0° and half the world permanently behind it. Auto-rotation
therefore cannot be the *only* way to see the far side.

Two manual controls exist, and both call `positionMap()` directly rather than
going through the animation loop, so **they work whether or not that loop is
running** — which is the entire point:

- **Drag** (`pointerdown`/`move`/`up`, so mouse, touch and pen alike). Pixel
  travel is converted through the SVG's own scale — `viewBox` is 960×480 under
  `xMidYMid meet`, so the drawing scale is the smaller of the two ratios — then
  divided by `GL.R` to give a trackball feel. The surface follows your finger.
- **Arrow keys**, 5° a press, 15° with Shift. The `<svg>` carries
  `tabindex="0"` and an `aria-label` so it is reachable by keyboard at all.

Two details that are easy to get wrong:

- **A drag that ends over a city must not install there.** `pointermove` sets
  `dragMoved` past a 3px threshold, and each node's click listener checks it.
  Because the browser delivers `click` *after* `pointerup`, the flag is cleared
  on a `setTimeout(…, 0)` rather than immediately — clearing it inline would
  let the stray click through.
- **`touch-action: none`** on the `<svg>`, or dragging the globe scrolls the
  page on touch devices instead.

Dragging also suspends auto-rotation for its duration (`if(!drag)` in
`spinLoop`), so the planet does not fight the hand holding it.

## Roadmap (not implemented — ideas only)

- **Globe polish.** Pole tilt (the current maths is yaw-only, so the poles
  cannot be brought into view), atmosphere glow, star field. None started.
- **PAN→LAN→MAN→WAN scale ladder.** The globe is the WAN rung; zooming into a
  region would open its metro fabric, and into that, a rack. Free movement up
  and down one continuous game with a single shared clock. Design only — see
  [`docs/design/2026-07-22-scale-ladder-and-opponents.md`](./docs/design/2026-07-22-scale-ladder-and-opponents.md).
- **Engine migration (Bevy/Fyrox).** Moving off the browser architecture
  entirely onto a Rust engine with a Cargo→WASM pipeline and an ECS design.
  This is a rewrite, not an upgrade, and would give up the zero-install
  property. Not committed, not started.

Note for anyone revisiting the 3D question: Hurricane Electric's
[3D network map](https://www.he.net/3d-map/) is HE's own proprietary in-house
tool — no public library or API behind it, confirmed by inspection — so there
was never anything to depend on directly. An earlier draft of this file claimed
[Globe.gl](https://github.com/vasturiano/globe.gl) could be "dropped in via a
CDN `<script>` tag without breaking the self-contained property"; **that was
wrong**, because a CDN tag is a network call and `ci.yml` fails the build on
one. Vendoring Three.js inline would have meant ~600 KB into a 39 KB file. The
hand-rolled orthographic projection was chosen precisely to avoid both.
