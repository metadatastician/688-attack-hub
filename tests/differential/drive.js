// Driver appended after the game script. Plays a scripted, fully deterministic
// run and prints one fingerprint line per tick.
//
// The point is DIFFERENTIAL: run this against the pre-increment-0 file and the
// post file under the same seed, and diff the output. Identical output is the
// only real evidence that "plumbing, zero behaviour change" is true. Parse-OK
// proves nothing, and this file has no other harness of any kind.
//
// Upgrades are bought on a fixed schedule rather than greedily, so the two runs
// make the same purchases at the same ticks regardless of any change to cost or
// income ordering.
// Buying schedule. It exists to reach CODE PATHS, not to play well. An earlier
// version bought stp at tick 360 and never bought pigeon at all, so planting a
// deliberate bug in either was undetectable — the run simply never executed
// those lines. A negative test that does not execute the code proves nothing,
// so the schedule front-loads every upgrade that gates a distinct branch and
// the driver REPORTS its coverage instead of anyone assuming it.
const ORDER = [
  "promis","stp","pigeon","slot","dhcp","mdix","cat6","nomgmt","tunnel",
  "jumbo","sfp","unlbl","subsea","dwdm","casc","ceil","dnr","duplex",
];

// The state SPLIT is the change under test, so the fingerprint has to read both
// shapes and normalise. Before: S.cms held policies, beat markers and `floss`
// together. After: S.pols and S.once. Comparing the raw containers would report
// a diff for the refactor itself rather than for any behaviour change.
const POLKEYS  = ["port","switch","bcp38","rpki","manrs","final"];
const ONCEKEYS = ["b15","b40","b70","floss"];
// Explicit codepoint comparator, and the reason is not style. Default .sort()
// is lexicographic by UTF-16 code unit, which is what we want — but the obvious
// "fix" a linter nudges you toward, .sort((a,b)=>a.localeCompare(b)), is
// LOCALE-SENSITIVE. In a harness whose entire purpose is byte-identical output
// across machines, ordering that depends on the environment's locale is the one
// thing it must never do. Saying it explicitly stops that edit being made later.
const byCodepoint = (a, b) => (a < b ? -1 : a > b ? 1 : 0);

const inPol  = k => (typeof S.pols !== "undefined") ? S.pols.has(k) : S.cms.has(k);
const inOnce = k => (typeof S.once !== "undefined") ? S.once.has(k) : S.cms.has(k);

function fingerprint() {
  const st = REGIONS.map(r => {
    const s = S.st[r.id];
    // st[].o is NEW in increment 0 — the old build has no such field, so it is
    // only compared when __WITHO__ is set (new-vs-new mutation tests). Including
    // it in the old-vs-new diff would report the field's existence as a
    // behaviour change.
    return `${r.id}:${s.s}:${s.f.toFixed(4)}` + (globalThis.__WITHO__ ? ":"+(s.o||"-") : "");
  }).join(",");
  return [
    S.tick,
    S.gbps.toFixed(6), S.total.toFixed(6), S.pp, S.spent,
    S.att.toFixed(6),
    domCount(),
    // ekey() normalises a|b vs b|a at write time — that IS one of the changes
    // under test, and it is representation, not behaviour. Normalise both sides
    // so the comparison tests the simulation rather than the key spelling.
    [...S.links].map(k => k.split("|").sort(byCodepoint).join("|")).sort(byCodepoint).join("+"),
    [...S.ups].sort(byCodepoint).join("+"),
    POLKEYS.filter(inPol).join("+"),
    ONCEKEYS.filter(inOnce).join("+"),
    S.deswitch, S.whispers, S.stormed ? 1 : 0,
    REGIONS.map(r => visLevel(r.id)).join(""),
    st,
  ].join(" | ");
}

S.phase = "pick";
click("lhr");                        // fixed opening move

// Two scenarios, because they answer different questions.
//   PLAY  — the economy as designed. Answers "does it still play the same?"
//           but only ever affords ~11 of 18 upgrades before the run ends, so
//           the dear ones (dwdm, duplex, dnr…) are never exercised.
//   COVER — the same run with headroom granted at tick 0, so every upgrade is
//           bought and every branch is live. Answers "is the comparison
//           actually looking at all the code?"
// Both sides of the diff get the identical grant, so COVER is still a valid
// differential — it changes the scenario, not the fairness of the comparison.
if (globalThis.__COVER__) { S.total = 400000; S.gbps = 400000; }
for (let i = 1; i <= 900; i++) {
  if (S.phase !== "run") break;
  // Ordered QUEUE, not a fixed-tick schedule. The schedule version fired once
  // at an exact tick and silently did nothing if PP was short that tick, so it
  // only ever bought 6 of 18 and half the negative tests were inert. Trying the
  // next unbought upgrade every tick is just as deterministic — affordability
  // is a pure function of state — and reaches every branch.
  const want = ORDER.find(id => !S.ups.has(id));
  if (want) {
    const u = UPGRADES.find(x => x.id === want);
    if (u && S.pp - S.spent >= u.c) buy(u);
  }
  if (S.tick === 100) whisper();
  if (S.tick === 200) whisper();
  if (S.tick === 260 && !S.stormed) storm();
  // link outward on a fixed cadence, always to the lowest-id linkable region
  if (S.tick % 7 === 0) {
    const cands = REGIONS.map(r => r.id).filter(canLink).sort(byCodepoint);
    if (cands.length) click(cands[0]);
  }
  step();
  console.log(fingerprint());
}
console.log("END phase=" + S.phase + " tick=" + S.tick + " peak=" + S.peak);
// Coverage, to stderr so it never pollutes the diff. Read it: an upgrade or
// policy missing here means every negative test that depends on it is inert.
const bought  = UPGRADES.map(u=>u.id).filter(id=>S.ups.has(id));
const missing = UPGRADES.map(u=>u.id).filter(id=>!S.ups.has(id));
const gotPol  = POLKEYS.filter(inPol);
console.error("COVERAGE upgrades " + bought.length + "/" + UPGRADES.length +
              (missing.length ? "  MISSING:" + missing.join(",") : "") +
              "  policies " + gotPol.length + "/" + POLKEYS.length +
              (gotPol.length < POLKEYS.length ? "  MISSING:" + POLKEYS.filter(k=>!inPol(k)).join(",") : "") +
              "  att=" + S.att.toFixed(1) + "  whispers=" + S.whispers + "  stormed=" + (S.stormed?1:0));
