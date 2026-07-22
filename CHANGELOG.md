<!--
SPDX-License-Identifier: CC-BY-SA-4.0
Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Orthographic globe view**, behind a FLAT / GLOBE toggle in the footer.
  Flat remains the default. Hand-rolled — no library, no build step, no
  network call — because the map data was already spherical and only the
  plate-carrée projection stood between it and a globe. Great-circle arcs via
  slerp, back-face culling, horizon clipping, and a rotation that runs on
  `requestAnimationFrame` so the planet stays live while the game clock is
  halted. Honours `prefers-reduced-motion`.
- **Drag and keyboard rotation for the globe.** Drag with mouse, touch or pen;
  or use the left/right arrow keys (5°, or 15° with Shift) — the map is
  keyboard-focusable and labelled. Both drive the projection directly rather
  than through the animation loop, so they work when auto-rotation is
  suppressed by `prefers-reduced-motion`. Without them, a reduced-motion user
  selecting GLOBE got a planet frozen at 0° with half the world unreachable,
  which was an accessibility fault rather than missing polish.

### Fixed

- **CodeQL default setup**, which had been failing at startup on every push:
  it was configured with an empty language list, because the repository
  detects as 100% HTML and CodeQL cannot target the game's inline `<script>`
  without splitting the file. Now scans the `actions` language instead, which
  covers the two workflows and passes with zero findings.
- Removed 23 dead `startup_failure` run records left by the pre-prune template
  state and by the CodeQL misconfiguration.
- `ARCHITECTURE.md` previously claimed Globe.gl could be added "via a CDN
  `<script>` tag without breaking the self-contained property". That was
  wrong — a CDN tag is a network call, which `ci.yml` fails the build on.
  Corrected.

### Roadmap (not started)

- Globe polish: pole tilt (the maths is yaw-only, so the poles cannot yet be
  brought into view), atmosphere glow, star field.
- PAN→LAN→MAN→WAN scale ladder, with the globe as the WAN rung — design only.
- Possible engine migration (Bevy/Fyrox) if the game grows beyond a browser
  idle-toy — see `ARCHITECTURE.md`. A rewrite, not an upgrade; not committed.

## [0.1.0] - 2026-07-21

### Added

- Initial import of `688-attack-hub.html` — a self-contained browser
  idle/strategy game (AS688, an unmanaged network repeater spreading across
  real-world internet exchange points).
- Full RSR documentation set (README, ARCHITECTURE, EXPLAINME, AUDIT,
  AFFIRMATION, GOVERNANCE, CONTRIBUTING, SECURITY, CODE_OF_CONDUCT,
  MAINTAINERS, CITATION) scaffolded from `hyperpolymath/rsr-template-repo`
  and pruned to the module set actually used, following the precedent set by
  this org's `f19-stealth-glider`.
- `ci.yml` (repository integrity checks) and `pages.yml` (GitHub Pages
  deployment of the game, packed by hand per this org's SHA-pinning policy).
- Machine-readable metadata under `.machine_readable/` and `.well-known/`.
- Licensed AGPL-3.0-or-later, matching the `metadatastician` org convention.
