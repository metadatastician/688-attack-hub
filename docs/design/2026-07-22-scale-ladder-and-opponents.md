<!--
SPDX-License-Identifier: CC-BY-SA-4.0
SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
# Design: the scale ladder and the rival routers

**Status: design only. None of this is built.** Written 2026-07-22, after the
orthographic globe landed. Nothing here should be read as a description of the
game as it exists — see `ARCHITECTURE.md` for that.

## The problem this is solving

The game has one decision in it. You choose which node to click, and then you
watch numbers rise.

That is not a content shortage, it is a structural one, and it is visible in
the upgrade list. All 18 entries in `UPGRADES` (`688-attack-hub.html:290–312`)
are **passive scalar multipliers**: `throughput ×1.25`, `×1.4`, `×1.8`,
`attention −15%`, `−20%`, `−25%`, `+3 hops`, `+5 hops`, `+8 hops`. Four trees,
eighteen entries, and every one of them changes a coefficient in a loop the
player is already watching. None of them changes what the player can *do*.

Two are exceptions, and they are the two everyone remembers: `pigeon` (RFC 1149
avian carriers) and `dnr` (labelled "DO NOT REMOVE" — *"nobody dares"*). They
work because the joke and the mechanic are the same object. That is the bar.

The second structural problem is that there is no opponent. `CMS`
(`688-attack-hub.html:313–320`) fires six scripted messages at fixed attention
thresholds — 20/35/50/65/80/100%. It cannot respond to anything you do. It is a
timer wearing a uniform.

**Design principle for everything below: upgrades must grant verbs, not
coefficients.** If a new mechanic can be expressed as a number in an existing
formula, it is the wrong mechanic.

## Constraints (non-negotiable)

Inherited from `0-AI-MANIFEST.a2ml` and enforced by `ci.yml` on every push:

- No `fetch(`, `XMLHttpRequest`, `WebSocket`, `eval(`, `new Function(`.
- One self-contained file, no build step, no dependency.
- **Opponent "personalities" are locally computed state machines.** There is no
  model call, and there never will be. "Selectable models" means selectable
  *difficulty personalities*, decided in-file.

There is also a tone constraint, which is easier to break than the technical
ones. The game's charm is slow, dry, bureaucratic menace —
`%SYS-0-DESWITCH: THE GREAT DESWITCHING HAS BEGUN`, and a forged ticket signed
by a J. Hubbard who does not exist. A twitch-arcade mode fights that voice. A
*broadcast-storm* minigame, about flooding rather than shooting, does not.

## Part 1 — The scale ladder

**PAN → LAN → MAN → WAN**, as a **zoom**, not a campaign. One continuous game,
free movement up and down, and — this is the load-bearing part — **one shared
clock**.

```
WAN (globe)   ── always running, NOC attention still rising
   │  zoom into "fra" (DE-CIX)
   ▼
MAN (metro)   ── Frankfurt exchange fabric
   │  zoom into one facility
   ▼
LAN (rack)    ── patch panels, one room
   │
   ▲  pop back up at any time
```

The core loop is the tension between rungs: **the WAN clock does not stop while
you are down in a LAN.** Descending to fix something local always costs you
something global. If descending is free, the ladder is just scenery.

### What the existing data model already supports

- `REGIONS[].cap` (`:240`) is currently a capacity scalar used in scoring.
  Under the ladder it becomes a **door**: how large the board is when you zoom
  into that region. Frankfurt (`cap: 10`) opens something bigger than Nairobi
  (`cap: 3`).
- `adj{}` (`:324–325`) is built once, flat, from `EDGES`. It becomes per-scale:
  a node's neighbours at one rung, and its internal topology at the next rung
  down.
- `visLevel()` (`:458`) — the three-state fog of war — is the best idea in the
  codebase and should govern every rung, not just the WAN.

### Open questions

- Does each rung have its own `S`, or one tree of state? (Leaning: one tree.)
- Is the LAN board generated or hand-authored per region? Generated risks
  sameness; hand-authored risks 20× the content cost.
- What does *losing* a LAN mean when you are standing in it?

## Part 2 — The rival routers

**1–4 opponents, asymmetric.** They do not want territory. They want you gone:
segment, isolate, reclaim.

This is the thematically correct answer, and it is worth stating why. A router
is the natural predator of a hub. Hubs flood every frame to every port; routers
and switches exist precisely to stop that by segmenting collision and broadcast
domains. Switched networks are what made hubs extinct. The game's own endgame
text already knows this — `THE GREAT DESWITCHING` is the invention of the
switch. So the opponents are not generic enemies; they are the thing that
historically killed the protagonist.

**`CMS` is retired.** Its six thresholds become opponent *actions*, chosen by
agents that react, rather than a script that arrives on schedule.

Each opponent has a **personality** and a **tier**, and spends on a mirrored
**router tree** — VLAN segmentation, sticky-MAC port security, BPDU guard,
storm control, RPKI — while the player spends on flooding.

Sketches, to be developed and costed:

| Opponent | Tier | Behaviour |
|---|---|---|
| **THE INCUMBENT** | 2 | A Cisco 2621 with 4,112 days of uptime. Slow. Never reboots. Never forgets a MAC. Buys sticky-MAC port security, then simply waits. |
| **THE CONSULTANT** | 4 | A six-week engagement. Re-architects aggressively and early, then the contract ends and it goes dormant — leaving its changes behind. |
| **THE COMPLIANCE LEAD** | 3 | Never touches the network. Files tickets. Raises attention everywhere at once. You cannot flood a policy. |

The personalities must be legible *from their behaviour on the map*, not from a
label in a menu. If a player cannot tell the Consultant from the Incumbent
without reading the tooltip, the design has failed.

## Part 3 — Upgrades that grant verbs

Three keystones, all real hub technology the game has not yet used.

### MAC flooding / CAM-table overflow

Overflow a switch's CAM table and it fails open — **it starts behaving like a
hub**. This is the single best mechanic available to this game, because it
means you do not destroy enemy infrastructure, you **degrade it into
yourself**. Territory capture and thematic identity become the same action.

It also gives the rival routers something to defend with that is equally real:
port security limits MAC addresses per port, which is exactly the counter.

### Spanning Tree as territory, not a modifier

Currently `stp` is a −35% number (`:310`). But STP is a *topology game*: root
bridge election, blocked ports, topology-change notifications. Winning the
root-bridge election makes you the literal centre of the tree — every frame
routes through you by the protocol's own rules, not by cheating. That is Risk-
like territorial play already latent in the theme, needing no new fiction.

### CDP/LLDP as vision

Neighbour-discovery protocols broadcast device identity unsolicited. That is
*exactly* "you have no eyes, you have twenty ears" (`:337`). This turns
`visLevel()` from a static adjacency rule into a **progression axis** — you
upgrade what you can overhear, rather than upgrading a multiplier.

### Further seams, unmined

Duplex mismatch from failed autonegotiation; storm control; BPDU guard;
VLAN double-tagging; IGMP snooping (unsnooped multicast *is* flooding — the
"multicast arcade mode" idea has a real protocol under it).

## Sequencing

Deliberately not one big build:

1. **Opponents replace `CMS`, plus the verb-granting upgrade rework.**
   Self-contained on the existing WAN map. Needs no ladder. This is the single
   biggest gameplay uplift available and should come first.
2. **Ladder rungs**, one scale per increment, each shipping playable.

## Explicitly rejected

- **Vendoring a 3D engine.** Settled when the globe was built; see
  `0-AI-MANIFEST.a2ml`.
- **A Space Invaders–style arcade mode.** Tonally wrong for a game whose best
  joke is a forged maintenance ticket. A flooding minigame is the version of
  this idea that survives.
- **Symmetric rival hubs.** Considered and not chosen: it is simpler to
  balance, but it costs the lonely-machine voice the intro spends its whole
  length establishing.
