<div align="center">

# 688 Attack Hub

### *AS688 · 10BASE-T · Unmanaged repeater · 20 port*

**A browser idle/strategy toy** about quietly spreading a rogue network
repeater across the world's real internet exchange points, one leaked segment
at a time — while the NOC's attention meter climbs toward "the Great
Deswitching."

</div>

---

## What this is

You are AS688: an unmanaged 20-port repeater with delusions of grandeur. Each
tick, you install at real-world internet exchange points — LINX, DE-CIX,
AMS-IX, Equinix SG, HKIX, and 15 others, laid out at their actual
longitude/latitude — and link them across real backbone routes. Every link
costs port points, contributes throughput, and raises **NOC ATTENTION**.
Eighteen upgrades across four trees (**Physical**, **Timing**, **Stealth**,
**Spread**) trade off speed, stealth, and reach. Attention crosses six
thresholds, each firing a real-sounding countermeasure message (port security,
a vendor switch refresh, BCP38 filtering, RPKI ROA enforcement, a MANRS
compliance audit) culminating at 100% in **THE GREAT DESWITCHING**.

Everything is flavour. There is no real target, no real exploit, and no
network call of any kind — see [`AUDIT.adoc`](./AUDIT.adoc) for what was
actually checked.

## Run it

- **Play in your browser:** <https://metadatastician.github.io/688-attack-hub/>
- **Play locally:** open `688-attack-hub.html` — self-contained, no server,
  no build step, nothing to install.
- **Serve it over http:// if you'd rather:** `bun run serve`. You almost never
  need this; the file opens fine from disk.

Any modern browser. No dependencies — nothing to install.

### Two query parameters

| | |
|---|---|
| `?seed=N` | Replays a run **exactly**, including across restart. |
| `?fast=N` | Runs the clock N× faster (capped at 40), so a whole game takes under a minute. |

`?seed=` matters more than it looks. Five `Math.random()` sites used to mean no
two runs were comparable, so "this feels too fast" could never be checked
against anything — balance was assessable only by feel. With a seed, "the
Pacific went dark on tick 40 at seed 7" is a reproducible observation.

They combine: <https://metadatastician.github.io/688-attack-hub/?seed=7&fast=20>

The footer carries a **FLAT / GLOBE** toggle. Flat is the plate-carrée world
map and the default; globe is a rotating orthographic projection of the same
data, hand-rolled in SVG with no 3D library. Both are the same game — the
projection is the only thing that changes.

In globe view you can **drag to rotate**, or use the **left/right arrow keys**
(hold Shift for a bigger step). The globe also turns on its own, unless your
system asks for reduced motion — in which case it stays still and the drag and
key controls are how you reach the far side.

## Documentation

| Document | What it answers |
|---|---|
| [`ARCHITECTURE.md`](./ARCHITECTURE.md) | The single-file structure: data (nodes/edges/upgrades), state, the render loop, and how the flat and globe projections share one `project()` seam. |
| [`EXPLAINME.adoc`](./EXPLAINME.adoc) | What's actually true about this repo, mapped to the file/line that backs each claim. |
| [`AUDIT.adoc`](./AUDIT.adoc) | What is verified (grep-checked), what is merely asserted, and what is explicitly *not* claimed — there is no formal proof ledger here, unlike this repo's sibling `f19-stealth-glider`. |
| [`AFFIRMATION.adoc`](./AFFIRMATION.adoc) | What was checkably true at one stamped commit. |
| [`CONTRIBUTING.md`](./CONTRIBUTING.md) | How to work on this repo. |
| [`GOVERNANCE.md`](./GOVERNANCE.md) | The (small) set of invariants this project won't trade away. |
| [`SECURITY.md`](./SECURITY.md) | The deliberately small threat model and how to report an issue. |
| [`DEBT.adoc`](./DEBT.adoc) | Known debt by kind — licence, docs, code, tests, CI/CD — with evidence for each, and what is deliberately *not* being fixed. |
| [`MAINTAINERS.adoc`](./MAINTAINERS.adoc) | Who maintains this and how decisions get made. |
| [`CODE_OF_CONDUCT.md`](./CODE_OF_CONDUCT.md) | Expected conduct and how to report a problem. |
| [`CHANGELOG.md`](./CHANGELOG.md) | Project history. |

Machine-readable metadata for agents lives in
[`0-AI-MANIFEST.a2ml`](./0-AI-MANIFEST.a2ml) and `.machine_readable/`.

## Tests

`tests/differential/run.sh` runs the game's simulation against a git baseline
under a fixed seed and diffs the state trajectory tick by tick. It answers one
question — *did this change alter how the game plays?* — which is exactly what
the Phase C refactors need and nothing more.

It is **not** a gate and **not** coverage. It needs `bun` and a baseline ref,
and choosing the baseline is a judgement, so CI does not run it.
[`AUDIT.adoc`](./AUDIT.adoc) records what it can and cannot see — including one
measured blind spot: a change smaller than the RNG can resolve is invisible to
it.

```
bun --version                        # needs bun
tests/differential/run.sh            # against HEAD
tests/differential/run.sh origin/main
```

## Licence

Three licences are in use here, and the split is deliberate:

| Licence | Covers |
|---|---|
| [AGPL-3.0-or-later](./LICENSE) | the game and the workflows |
| CC-BY-SA-4.0 | the human documentation |
| MPL-2.0 | scripts and launchers |

AGPL matches this repository's siblings in the `metadatastician` org. See
[`LICENSES/`](./LICENSES/) for the full text of all three.

Two gaps are known and recorded in [`DEBT.adoc`](./DEBT.adoc): the game file
itself carries no SPDX header, and there is no `REUSE.toml`/`dep5` mapping — so
files that cannot hold a comment (`package.json`, `CITATION.cff`) are covered by
nothing. Both are flagged rather than fixed, because licence changes here are
deliberately manual.

## Origin

This game is original fictional content — not derived from, and not a copy
of, the 1997 commercial submarine simulator "688(I) Hunter/Killer" / "688
Attack Sub". The name is coincidental wordplay on the AS688 fictional
autonomous-system number used in-game.
