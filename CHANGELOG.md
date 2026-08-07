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

- **Seeded, replayable runs.** `?seed=N` replays a run exactly, including
  across restart; `?fast=N` runs the clock up to 40× so a whole game can be
  watched in under a minute. Both read `location.search`, a read-only DOM
  property — no fetch, no eval, no dependency, still one self-contained file.
  Unseeded, the seed comes from the clock, so ordinary play is as varied as it
  was. This matters beyond convenience: `Math.random()` sat at five sites, so
  no two runs were comparable and balance could not be assessed at all, only
  felt.
- **A differential test** at `tests/differential/`. It runs the simulation
  against a git baseline under the same seed and diffs the state trajectory
  tick by tick, which is the only way to check a refactor's claim of "no
  behaviour change" in a file with no other harness. Not a gate and not
  coverage — it needs `bun` and a baseline ref, and `AUDIT.adoc` records what
  it cannot see.
- **`DEBT.adoc`**, a debt register by kind (licence, documentation, code,
  tests/proof, CI/CD), with evidence for every entry and an explicit
  distinction between what is owed, what is flagged for the owner, and what is
  a deliberate limitation rather than a TODO.

### Changed

- **`S.cms` split into `S.pols` and `S.once`.** It had been holding three
  unrelated things — the six countermeasure keys, the narrative-beat markers,
  and a one-shot flag — so "is a policy in force" and "have we said this line
  yet" were the same question. `S.cms` was deleted rather than aliased, so any
  missed reference throws on the first tick.
- **One write path for three things that had several**: `setOwn()` is now the
  only writer of region state (six sites assigned it directly, one inside a
  loop in `step()`); `ekey()` normalises link keys at write time, so reads no
  longer have to check both orders; `mods()` holds every upgrade and policy
  coefficient in one memoised place. `has()` is kept for the one-bit behaviour
  switches, because a boolean is the right expression of a conditional.
- **`package.json` no longer runs Python.** `serve` was
  `python3 -m http.server`; Python is banned estate-wide with no exceptions.
  Replaced with `bun run scripts/serve.js`, which needs no dependency and keeps
  the repo's "nothing to install" claim true. You still do not need it — the
  file opens from disk.

### Fixed

- **A malformed lockfile line was taking out every workflow in the repo.** A
  reusable-caller entry had been written into `actions.lock`'s `dependencies:`
  map instead of `workflows:`; every other value there is an object describing
  a pinned action, so a bare list made the file unparseable, and an unparseable
  lockfile is rejected before any job starts. `ci`, `pages` and `Secret
  Scanner` all went red in the same commit while nothing about them changed.
- **Six files linked to a `GOVERNANCE.adoc` that does not exist** — the file is
  `GOVERNANCE.md`. Every relative link in the documentation set now resolves.
- **Two funding files contradicted each other.** `.github/funding.yml` said
  `github: metadatastician`; `.github/FUNDING.yml` said in prose that no
  funding is solicited. GitHub honours the uppercase name, so the lowercase one
  was an inert contradiction. Removed.

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

- **`main` is green again.** The 2026-07-26 estate sweeps (#6, #8) left `ci` and a
  swept-in CodeQL workflow both failing. Neither failure involved the game, whose
  bytes are unchanged. Details below; the common thread is that a sweep copied
  another repository's files into this one.
- **`CODE_OF_CONDUCT.md` no longer claims to be squisher-corpus's.** The sweep
  replaced this repo's Code of Conduct with one carrying an undeleted
  `TEMPLATE INSTRUCTIONS` block. That block is self-detonating: its own first
  line instructs the reader to replace all values, using a literal doubled-brace
  `PLACEHOLDER` token to say so — and that literal is what `ci.yml`'s placeholder
  gate matches, so the block trips the gate even when every real token has been
  correctly substituted. The gate was working exactly as designed: it caught a
  real regression. (This entry deliberately describes the token rather than
  quoting it, because quoting it here would fail the build — the gate scans the
  whole tree, documentation included.) The substituted values were squisher-corpus's, so the document
  pledged a harassment-free experience in "Squisher Corpus" and pointed its
  Discussions link at `hyperpolymath/squisher-corpus`. Restored the project name,
  the correct link and the SPDX header the sweep deleted; kept the two genuine
  grammar fixes the sweep did make; reverted the reporting SLA to this repo's own
  prior "5 business days", because promising 48-hour response on a one-file toy
  is the kind of aspirational overclaim `AUDIT.adoc` exists to prevent. Also
  fixed "a maintainers member" (ungrammatical in both versions), dropped an
  "Anonymous Form" row whose link never existed, and replaced references to a
  "Perimeter" access model that is defined nowhere in this repo.
- **Removed the swept-in `.github/workflows/codeql.yml`.** Every run of it failed
  with `Code Scanning could not process the submitted SARIF file: CodeQL analyses
  from advanced configurations cannot be processed when the default setup is
  enabled`. PR #9 had repointed its action SHA, which fixed resolution and
  thereby exposed this deeper conflict. Default setup remains configured, green,
  and sufficient. Note this file's existence already violated a documented
  deviation in `.machine_readable/rsr-profile.a2ml`, which has said "No advanced
  codeql.yml" since the repo was created — so this is a restoration of
  conformance, not a new decision.
- **Removed `.github/settings.yml`, which declared this repository to be
  `paint-type`** — name, description and homepage copied verbatim from a sibling,
  plus required status checks (`Cargo check + clippy + fmt`, `Cargo test`,
  `analyze (javascript-typescript, none)`) that no workflow here produces, in a
  repo with no `Cargo.toml`. It configured nothing, because the Probot Settings
  app is not applying to this repository; had it ever been applied, the repo would
  have tried to rename itself and acquired required checks that can never report,
  which presents as permanently-pending rather than red.
- **The `paint-type` leak was wider than `settings.yml`** — 18 references across
  11 files, and two were live misroutes rather than cosmetic: the issue-template
  chooser sent "Discussions" *and* "Report a security vulnerability" to
  `metadatastician/paint-type`, so a security reporter would have filed a private
  advisory against the wrong repository. Corrected throughout, including two
  Level-2 AI manifests that described themselves as belonging to paint-type.
- **Added the missing SPDX headers to two `.a2ml` files.** `ci.yml` requires one
  on every `.a2ml`, and the two swept-in template manifests had none. This was a
  *hidden second failure*: the placeholder step fails before the SPDX step runs,
  so fixing the Code of Conduct alone would have moved the red build down one step
  rather than clearing it.
- **Two documents had been silently invalidated by the sweep and are now accurate
  again without being edited.** `ARCHITECTURE.md` describes
  `.github/workflows/` as "ci.yml, pages.yml" and `AUDIT.adoc` says CodeQL
  "covers the two workflows" — both true before the sweep and after this change,
  but false for the eight days a third workflow existed.
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
