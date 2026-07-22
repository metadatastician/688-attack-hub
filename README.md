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
- **Serve it locally instead of double-clicking:** `npm run serve` (plain
  `python3 -m http.server`, nothing fancier).

Any modern browser. No dependencies — nothing to install.

The footer carries a **FLAT / GLOBE** toggle. Flat is the plate-carrée world
map and the default; globe is a rotating orthographic projection of the same
data, hand-rolled in SVG with no 3D library. Both are the same game — the
projection is the only thing that changes.

## Documentation

| Document | What it answers |
|---|---|
| [`ARCHITECTURE.md`](./ARCHITECTURE.md) | The single-file structure: data (nodes/edges/upgrades), state, the render loop, and how the flat and globe projections share one `project()` seam. |
| [`EXPLAINME.adoc`](./EXPLAINME.adoc) | What's actually true about this repo, mapped to the file/line that backs each claim. |
| [`AUDIT.adoc`](./AUDIT.adoc) | What is verified (grep-checked), what is merely asserted, and what is explicitly *not* claimed — there is no formal proof ledger here, unlike this repo's sibling `f19-stealth-glider`. |
| [`AFFIRMATION.adoc`](./AFFIRMATION.adoc) | What was checkably true at one stamped commit. |
| [`CONTRIBUTING.md`](./CONTRIBUTING.md) | How to work on this repo. |
| [`GOVERNANCE.adoc`](./GOVERNANCE.adoc) | The (small) set of invariants this project won't trade away. |
| [`SECURITY.md`](./SECURITY.md) | The deliberately small threat model and how to report an issue. |
| [`CHANGELOG.md`](./CHANGELOG.md) | Project history. |

Machine-readable metadata for agents lives in
[`0-AI-MANIFEST.a2ml`](./0-AI-MANIFEST.a2ml) and `.machine_readable/`.

## Licence

Code and documentation are [AGPL-3.0-or-later](./LICENSE), matching this
repository's siblings in the `metadatastician` org. See
[`LICENSES/`](./LICENSES/) for the full text of every licence referenced in
this tree.

## Origin

This game is original fictional content — not derived from, and not a copy
of, the 1997 commercial submarine simulator "688(I) Hunter/Killer" / "688
Attack Sub". The name is coincidental wordplay on the AS688 fictional
autonomous-system number used in-game.
