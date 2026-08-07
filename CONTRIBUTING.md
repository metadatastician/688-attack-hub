<!--
SPDX-License-Identifier: CC-BY-SA-4.0
Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
-->
# Contributing

This repository is one HTML file, two small helper directories, and a
documentation set. Please read this before opening a PR — most of it is short,
and the parts that are not are the parts people get wrong.

## Getting it running

```
git clone https://github.com/metadatastician/688-attack-hub.git
cd 688-attack-hub
```

That's the whole setup. **Open `688-attack-hub.html` in a browser.** There is no
build step, no package to install, and no toolchain to provision — the game is
one self-contained file and always has been.

If you want it on `http://` rather than `file://`:

```
bun run serve      # then http://localhost:8000
```

[Bun](https://bun.sh) is the only optional tool, and it is only needed for that
server and for the differential test below. Nothing else uses it.

> **Not Nix, not Python.** An earlier version of this file told you to run
> `nix develop`, and `package.json` used to shell out to `python3 -m
> http.server`. Nix is retired estate-wide in favour of Guix, and Python is
> banned outright. Neither appears here any more. Where a real language is
> needed the estate's choices are Rust, Julia, AffineScript or Elixir depending
> on the job — but this repository needs none of them, which is rather the
> point of it.

## What is actually here

```
688-attack-hub/
├── 688-attack-hub.html          the entire game — data, state, render loop
├── tests/differential/          diffs the simulation against a git baseline
├── scripts/serve.js             the optional local server
├── docs/design/                 design notes, including the Phase C sequence
├── .machine_readable/           agent-facing metadata (descriptiles, contractiles)
├── .well-known/                 ai.txt, humans.txt, security.txt
├── .github/                     workflows, issue templates, CODEOWNERS
└── LICENSES/                    full text of all three licences in use
```

There is **no** `src/`, `lib/`, `spec/`, `extensions/`, `plugins/` or
`tools/`, and no `Justfile`, `Cargo.toml` or `flake.nix`. If you see those named
anywhere in this repo's documentation, that is a bug — please report it.
`ARCHITECTURE.md` is authoritative on structure.

## Before you open a PR

**Read `AUDIT.adoc`.** It records what is verified, what is merely asserted, and
what is explicitly not claimed. This repo deliberately makes fewer formal claims
than its siblings, and PRs that make it sound more rigorously verified than it
is will be asked to change — overclaiming is the specific failure that document
exists to prevent.

**Read `DEBT.adoc`** if you are fixing something. It may already be recorded,
including several things that are deliberately *not* being fixed and why.

### If you touch the simulation

Run the differential test. It compares the game's behaviour against a baseline
under a fixed seed and diffs the state trajectory tick by tick:

```
tests/differential/run.sh origin/main
```

Any change that is *supposed* to preserve behaviour must come out identical. A
parse check proves nothing here; there is no other harness.

Three rules the code enforces on itself, and going around them is a bug:

- **Never call `Math.random()`** — use `rnd()`. Seeded replay (`?seed=`) is the
  only reason the game's balance can be assessed at all, and one raw
  `Math.random()` breaks it.
- **Never assign region state directly** — `setOwn()` is the only writer.
- **`S.cms` is gone**, split into `S.pols` and `S.once`. It was deleted rather
  than aliased on purpose, so a stale reference throws instead of silently
  working. Don't bring it back.

### CI will check five things

`ci.yml` runs greps, and is named `integrity` rather than `verify` for that
reason: the file is well-formed HTML; there is no `fetch`/`eval`/`WebSocket`/
`new Function`; no unsubstituted placeholder tokens anywhere in the tree; SPDX
on every `.a2ml`; every action ref pinned to a full commit SHA.

Two sharp edges to know about, because both have bitten:

- `fetch\(` has **no word boundary**, so a helper named `prefetch(` fails the
  build.
- The placeholder scan runs over the **whole tree**, so a placeholder token
  written as an *example* in a design document fails CI exactly as a real leak
  would.

## The Tri-Perimeter Contribution Framework

This project uses the estate's TPCF, which is defined in full in
[`CODE_OF_CONDUCT.md`](./CODE_OF_CONDUCT.md#enforcement-across-perimeters). It
is a graded-trust model, not a permissions table — the point is what a change
can *break*, not who is allowed to type.

| | | In this repo |
|---|---|---|
| 🔒 **Perimeter 1 — Core** | maintainers only | `688-attack-hub.html`, `.github/workflows/`, `LICENSE`/`LICENSES/`, `.well-known/` |
| 🧠 **Perimeter 2 — Expert** | trusted contributors | `tests/differential/`, `scripts/`, `.machine_readable/`, `ARCHITECTURE.md`, `AUDIT.adoc` |
| 🌱 **Perimeter 3 — Community** | open to all | `docs/`, `README.md`, `DEBT.adoc` entries, issues, discussions, the wiki |

A first contribution is very welcome at Perimeter 3. Corrections to the
documentation are genuinely useful here: this file was itself wrong for months,
describing a directory tree that does not exist.

Because the game is a single file, almost any gameplay change is Perimeter 1.
That is not gatekeeping — it is that one file has no module boundaries, so a
small edit can reach anything. Open an issue first and it will get a real
answer.

## Reporting a bug

Use the [issue templates](https://github.com/metadatastician/688-attack-hub/issues/new/choose).

**For gameplay or balance problems, include the seed.** Add `?seed=7` to the
URL and it replays exactly; without one the report is not reproducible and
usually not actionable. `?fast=20` will get you to the interesting part faster.

Security reports go through `SECURITY.md`, not the issue tracker.

## Branch and commit conventions

```
feat/…      fix/…      docs/…      test/…      refactor/…      security/…
```

[Conventional Commits](https://www.conventionalcommits.org/) for the subject
line. For the body: say what was wrong and how you know, not just what you
changed. If you claim something is verified, say what you ran.

## Licence

Contributions are accepted under the licence of the file you are editing —
AGPL-3.0-or-later for the game and workflows, CC-BY-SA-4.0 for documentation,
MPL-2.0 for scripts. See `README.md` for the split and `DEBT.adoc` for two known
gaps in how it is recorded.
