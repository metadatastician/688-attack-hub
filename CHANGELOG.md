<!--
SPDX-License-Identifier: CC-BY-SA-4.0
Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Roadmap (not started)

- Possible 3D globe view via Globe.gl, replacing the flat SVG map — see
  `ARCHITECTURE.md`.
- Possible engine migration (Bevy/Fyrox) if the game grows beyond a browser
  idle-toy — see `ARCHITECTURE.md`. Not the same change as the above; not
  committed to either.

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
