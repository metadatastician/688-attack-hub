<!--
SPDX-License-Identifier: CC-BY-SA-4.0
Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
## What this changes

<!-- One or two sentences. What is different after this PR? -->

## Why

<!-- Link the issue if there is one. If this changes gameplay or balance, say
     what problem it solves. -->

## Checklist

- [ ] I opened `688-attack-hub.html` in a browser and played through the change.
- [ ] If I touched `688-attack-hub.html`, it still contains no `fetch`,
      `XMLHttpRequest`, `WebSocket`, `eval(`, or `new Function(` — the
      invariant `ci.yml`'s `integrity` job checks on every push.
- [ ] I added no dependency and no build step (`package.json` has no
      `dependencies`).
- [ ] Every new or changed `.a2ml` file has
      `# SPDX-License-Identifier: AGPL-3.0-or-later` as its first line.
- [ ] No unsubstituted doubled-brace template placeholders remain.
- [ ] Any new GitHub Action `uses:` is pinned to a full commit SHA, with a
      trailing version comment.

## As applicable

- [ ] `.machine_readable/descriptiles/STATE.a2ml` updated (if project state changed)
- [ ] `AUDIT.adoc` / `AFFIRMATION.adoc` updated (if what's verified about this repo changed)
- [ ] `CHANGELOG.md` updated
