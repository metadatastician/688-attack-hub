#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
#
# Differential test: run the game's simulation against a git baseline under an
# identical seed and diff the state trajectory tick by tick.
#
# WHY IT EXISTS. This repo is one self-contained HTML file with no build step
# and, until now, no test of any kind. The Phase C increments are refactors that
# claim "zero behaviour change", and that claim is not checkable by reading. It
# is checkable by running both versions on the same seed and diffing.
#
# WHAT IT IS NOT. It is not wired to CI and it is not a gate. It needs a
# baseline commit to compare against, which is a judgement, not a constant. Do
# not describe it as coverage. AUDIT.adoc says the same.
#
# Usage:  tests/differential/run.sh [baseline-git-ref]     (default: HEAD)
set -euo pipefail
cd "$(dirname "$0")/../.."
BASE="${1:-HEAD}"
GAME=688-attack-hub.html
BUN="${BUN:-bun}"
command -v "$BUN" >/dev/null || { echo "bun not found; set BUN=/path/to/bun" >&2; exit 2; }

T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
extract(){ awk '/^<script>/{f=1;next} /^<\/script>/{f=0} f'; }
extract < "$GAME" > "$T/new.js"
git show "$BASE:$GAME" | extract > "$T/old.js"
# The baseline predates the seeded rng, so give it the same one — otherwise the
# two runs are not comparable at all and the diff is meaningless.
if ! grep -q 'mulberry32' "$T/old.js"; then
  sed -i 's/Math\.random()/rnd()/g' "$T/old.js"
  cat > "$T/shim.js" <<'SHIM'
function mulberry32(a){return function(){a|=0;a=a+0x6D2B79F5|0;let t=Math.imul(a^a>>>15,1|a);t=t+Math.imul(t^t>>>7,61|t)^t;return((t^t>>>14)>>>0)/4294967296}}
const SEED=__SEED__>>>0;
let rnd=mulberry32(SEED);
SHIM
fi
build(){ # 1=body 2=out 3=seed 4=cover 5=witho
  # NB: an `a && b && c` chain here returns 1 when the guard is false, and under
  # `set -e` that aborts the whole script with no message. Use an explicit if.
  { echo "globalThis.__SEARCH__=\"?seed=$3\"; globalThis.__COVER__=$4; globalThis.__WITHO__=$5;"
    cat tests/differential/prelude.js
    if [ -f "$T/shim.js" ] && [ "$1" = "$T/old.js" ]; then sed "s/__SEED__/$3/" "$T/shim.js"; fi
    cat "$1"
    cat tests/differential/drive.js
  } > "$2"; }

pass=0; fail=0
for MODE in false true; do
  for SEED in 12345 7 99 1 20260805; do
    build "$T/old.js" "$T/o.js" "$SEED" "$MODE" false
    build "$T/new.js" "$T/n.js" "$SEED" "$MODE" false
    "$BUN" "$T/o.js" > "$T/o.out" 2>"$T/o.err" || { echo "  ERROR baseline run failed:"; sed 's/^/        /' "$T/o.err" | head -6; exit 1; }
    "$BUN" "$T/n.js" > "$T/n.out" 2>"$T/n.cov" || { echo "  ERROR current run failed:"; sed 's/^/        /' "$T/n.cov" | head -6; exit 1; }
    NAME=$([ "$MODE" = true ] && echo COVER || echo PLAY)
    if diff -q "$T/o.out" "$T/n.out" >/dev/null; then
      pass=$((pass+1)); printf '  PASS  %-5s seed %-9s %s ticks\n' "$NAME" "$SEED" "$(wc -l < "$T/n.out")"
    else
      fail=$((fail+1)); printf '  FAIL  %-5s seed %-9s diverges at tick %s\n' "$NAME" "$SEED" \
        "$(diff "$T/o.out" "$T/n.out" | grep -m1 '^<' | cut -d' ' -f2)"
      diff "$T/o.out" "$T/n.out" | head -4 | cut -c1-160 | sed 's/^/        /'
    fi
  done
done
echo
echo "coverage of the two scenarios (they are complementary — read both):"
for MODE in false true; do
  build "$T/new.js" "$T/n.js" 1 "$MODE" false
  "$BUN" "$T/n.js" >/dev/null 2>"$T/cov" || true
  printf '  %-5s %s\n' "$([ "$MODE" = true ] && echo COVER || echo PLAY)" "$(sed 's/\x1b\[[0-9;]*m//g' "$T/cov")"
done
echo
echo "identical: $pass   diverging: $fail   (baseline $BASE)"
[ "$fail" -eq 0 ]
