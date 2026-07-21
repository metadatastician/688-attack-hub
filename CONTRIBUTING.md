<!--
SPDX-License-Identifier: CC-BY-SA-4.0
Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
# Contributing

## Quick start

```bash
git clone https://github.com/metadatastician/688-attack-hub.git
cd 688-attack-hub
```

There is no build, no dependency install, and no toolchain to set up — the
whole game is `688-attack-hub.html`. Open it directly in a browser to play,
or `npm run serve` to serve it over `http://localhost:8000` instead.

### Repository structure

```
688-attack-hub/
├── 688-attack-hub.html   # the entire game — see ARCHITECTURE.md
├── .github/workflows/    # ci.yml, pages.yml
├── .machine_readable/    # descriptiles + contractiles (agent-facing metadata)
├── .well-known/          # ai.txt, humans.txt, security.txt
├── LICENSE / LICENSES/
└── (the documentation set linked from README.md)
```

---

## How to contribute

### Reporting bugs

Before reporting: search existing issues, and check `main` in case it's
already fixed. When reporting, include what you did, what you expected, and
what actually happened — a browser/OS is usually all the environment detail
that matters here, since there's no build to go wrong.

### Suggesting changes

Balance changes (upgrade costs, attention thresholds), new upgrades, and new
exchange points/routes are all reasonable to propose via issue before
sending a PR — game balance is a taste call the maintainer wants to weigh in
on before code is written.

### Your first contribution

- [`good first issue`](https://github.com/metadatastician/688-attack-hub/labels/good%20first%20issue)
- [`help wanted`](https://github.com/metadatastician/688-attack-hub/labels/help%20wanted)
- [`documentation`](https://github.com/metadatastician/688-attack-hub/labels/documentation)

---

## Development workflow

### Branch naming

```
docs/short-description       # Documentation
fix/issue-number-description  # Bug fixes
feat/short-description        # New upgrades/mechanics/regions
```

### Commit messages

[Conventional Commits](https://www.conventionalcommits.org/):
```
<type>(<scope>): <description>
```

### Before opening a PR

- Open the game in a browser and actually play through the change.
- If you touched `688-attack-hub.html`, re-run the checks `ci.yml` runs
  locally first:
  ```bash
  grep -E 'fetch\(|XMLHttpRequest|WebSocket|eval\(|new Function\(' 688-attack-hub.html && echo "FIX: network/eval primitive found" || echo ok
  ```
- If you touched anything under `.machine_readable/`, keep the SPDX header
  on every `.a2ml` file and don't reintroduce unsubstituted doubled-brace
  template tokens.
- Don't add a build step, a bundler, or a dependency without discussing it
  first in an issue — "one self-contained file, nothing to install" is a
  deliberate property of this repo (see `GOVERNANCE.adoc`), not an oversight.

### Review

The sole maintainer (`@hyperpolymath`, per `MAINTAINERS.adoc`) reviews PRs;
see `GOVERNANCE.adoc` for the full decision-making process.
