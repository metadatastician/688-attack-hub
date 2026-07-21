<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- Copyright (c) 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk> -->

# Security Policy

## The honest threat model

688 Attack Hub is a single, self-contained HTML file that runs entirely in
the browser. It has:

- **no runtime dependencies** — nothing from npm, no CDN, no vendored
  libraries;
- **no network access** — the game makes no `fetch`, `XMLHttpRequest`, or
  `WebSocket` calls, checked by hand at repo creation and re-checked by
  `ci.yml` on every push;
- **no server component**, no backend, and no deployed service beyond the
  static GitHub Pages copy;
- **no user accounts, no authentication, no persistence, and no telemetry** —
  it collects and stores nothing about the person playing it;
- **no file, clipboard, camera, microphone, or location access.**

Nothing in that list is aspirational; each is checkable directly in
`688-attack-hub.html`, and the network/eval check is enforced by CI (see
`AUDIT.adoc` for exactly what is and isn't verified).

The realistic consequence is that the attack surface is very small. A
vulnerability here would most plausibly be one of:

1. **Supply-chain compromise of the published artefact** — the file served
   from GitHub Pages differing from the file in the repository.
2. **A CI/workflow weakness** — an unpinned or compromised GitHub Action.
3. **A browser-side flaw in the bundle itself**, such as an injection path
   through URL parameters or `localStorage` (the game does not currently use
   either, but this would be the place to look if that changes).

## Supported versions

| Version | Supported |
|---------|-----------|
| `main` (latest commit) | Yes |
| Anything else | No |

This is a small project with a single maintainer and no release branches.
Security fixes land on `main`; there is no backporting.

## Reporting a vulnerability

**Please do not open a public issue for a security report.**

Use GitHub's private vulnerability reporting:

> **Security** tab → **Report a vulnerability**

on <https://github.com/metadatastician/688-attack-hub>.

If that is unavailable to you, contact the maintainer through the address
listed in [`.well-known/security.txt`](.well-known/security.txt).

Please include what you did, what happened, what you expected, and the
browser and version.

### What to expect

| Stage | Target |
|-------|--------|
| Acknowledgement | 7 days |
| Initial assessment | 14 days |
| Fix or documented decision not to fix | 90 days |

These are targets for a volunteer single-maintainer project, not a
contractual SLA. If you have not heard back within the acknowledgement
window, please chase — it means the message was missed, not ignored.

You will be credited in the release notes unless you prefer otherwise. There
is no bug bounty.

## Out of scope

The following are not vulnerabilities in this project:

- **Cheating.** The game is client-side and fully open source. Editing the
  page's JavaScript to give yourself more port points is not a security
  issue — it is the licence working as intended.
- **Reports of "no Content-Security-Policy"** on a static file with no
  network access and no third-party content.
- **Automated scanner output submitted without a demonstrated impact.**
- **The game's flavour text.** The upgrades and NOC countermeasures are
  written as network-engineering jokes, not as a real attack tool or a
  claim about real-world network security practice — see `AUDIT.adoc`.

## Security practices in this repository

- Every GitHub Action is **pinned to a full commit SHA**, never a tag or
  branch. `ci.yml` fails the build otherwise, and the organisation also
  enforces `sha_pinning_required`, so an unpinned action does not merely
  fail review — it fails to start at all.
- **Code scanning** is enabled via GitHub's default setup (actions and
  javascript, extended query suite, weekly).
- **Dependabot** monitors GitHub Actions versions. There are no package
  ecosystems to monitor, because there are no packages.
- `ci.yml` asserts on every push that the game makes no network calls and no
  dynamic-code execution.
- The project is **dependency-free by design**, which removes the largest
  single source of vulnerabilities in comparable JavaScript projects.
