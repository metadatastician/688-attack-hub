# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# INIT — Bootstrap a new project from this template
#
# Imported by ../../Justfile via `import? "build/just/init.just"`.
# Variables (project, OWNER, REPO, version, tier) and the `set shell` directive
# are inherited from the root Justfile.

# Interactive project bootstrap — replaces all {{PLACEHOLDER}} tokens
# Optional archetype argument (e.g. `just init julia-library`) applies an
# archetype overlay: see archetypes/README.adoc and ADR-0003.
init archetype="":
    #!/usr/bin/env bash
    set -euo pipefail

    echo "═══════════════════════════════════════════════════"
    echo "  RSR Project Bootstrap"
    echo "═══════════════════════════════════════════════════"
    echo ""

    # --- Archetype overlay data (ADR-0003) ---
    ARCHETYPE='{{archetype}}'
    ARCH_FILE=""
    ARCH_PRESET=""
    if [ -n "$ARCHETYPE" ]; then
        ARCH_FILE="archetypes/${ARCHETYPE}/ARCHETYPE.a2ml"
        if [ ! -f "$ARCH_FILE" ]; then
            echo "Error: unknown archetype '${ARCHETYPE}'. Available:"
            ls -1 archetypes 2>/dev/null | grep -v 'README' || echo "  (none)"
            exit 1
        fi
        ARCH_PRESET=$(sed -n 's/^preset = "\(.*\)"$/\1/p' "$ARCH_FILE" | head -1)
        echo "Archetype: ${ARCHETYPE}${ARCH_PRESET:+  (capability preset: $ARCH_PRESET)}"
        echo ""
    fi

    # --- Load defaults from config (if exists) ---
    # Create yours: ~/.config/rsr/defaults
    # Format: OWNER=myorg  AUTHOR="My Name"  AUTHOR_EMAIL=me@example.org ...
    DEFAULTS="${XDG_CONFIG_HOME:-$HOME/.config}/rsr/defaults"
    if [ -f "$DEFAULTS" ]; then
        echo "Loading defaults from $DEFAULTS"
        # shellcheck source=/dev/null
        source "$DEFAULTS"
        echo ""
    fi

    # --- Required values (pre-filled from defaults if available) ---
    read -rp "Project name (human-readable, e.g. My Project): " PROJECT_NAME
    [ -z "$PROJECT_NAME" ] && echo "Error: project name required" && exit 1

    read -rp "Repository slug (e.g. my-project): " REPO
    [ -z "$REPO" ] && echo "Error: repo slug required" && exit 1

    read -rp "Owner [${OWNER:-}]: " _OWNER
    OWNER="${_OWNER:-${OWNER:-}}"
    [ -z "$OWNER" ] && echo "Error: owner required" && exit 1

    read -rp "Author full name [${AUTHOR:-}]: " _AUTHOR
    AUTHOR="${_AUTHOR:-${AUTHOR:-}}"
    [ -z "$AUTHOR" ] && echo "Error: author name required" && exit 1

    read -rp "Author email [${AUTHOR_EMAIL:-}]: " _AUTHOR_EMAIL
    AUTHOR_EMAIL="${_AUTHOR_EMAIL:-${AUTHOR_EMAIL:-}}"
    [ -z "$AUTHOR_EMAIL" ] && echo "Error: email required" && exit 1

    # --- Optional values (pre-filled from defaults if available) ---
    read -rp "Author organization [${AUTHOR_ORG:-none}]: " _AUTHOR_ORG
    AUTHOR_ORG="${_AUTHOR_ORG:-${AUTHOR_ORG:-}}"

    read -rp "Previous/alt email [${AUTHOR_EMAIL_ALT:-none}]: " _AUTHOR_EMAIL_ALT
    AUTHOR_EMAIL_ALT="${_AUTHOR_EMAIL_ALT:-${AUTHOR_EMAIL_ALT:-}}"

    read -rp "Project description []: " PROJECT_DESCRIPTION

    read -rp "Forge domain [${FORGE:-github.com}]: " _FORGE
    FORGE="${_FORGE:-${FORGE:-github.com}}"

    read -rp "Security contact email [${SECURITY_EMAIL:-$AUTHOR_EMAIL}]: " _SECURITY_EMAIL
    SECURITY_EMAIL="${_SECURITY_EMAIL:-${SECURITY_EMAIL:-$AUTHOR_EMAIL}}"

    read -rp "Conduct contact email [${CONDUCT_EMAIL:-$AUTHOR_EMAIL}]: " _CONDUCT_EMAIL
    CONDUCT_EMAIL="${_CONDUCT_EMAIL:-${CONDUCT_EMAIL:-$AUTHOR_EMAIL}}"

    read -rp "Project type (library|binary|monorepo|service|website) [library]: " PROJECT_TYPE
    PROJECT_TYPE="${PROJECT_TYPE:-library}"

    read -rp "Website URL [https://${FORGE}/${OWNER}/${REPO}]: " WEBSITE
    WEBSITE="${WEBSITE:-https://${FORGE}/${OWNER}/${REPO}}"

    read -rp "OpenSSF Best Practices project ID (blank if not yet registered) []: " OPENSSF_BP_ID

    # --- Container values (optional — only relevant if container/ exists) ---
    if [ -d "container" ]; then
        echo ""
        echo "── Container configuration (optional) ─────────"
        read -rp "Service name [${REPO}]: " _SERVICE_NAME
        SERVICE_NAME="${_SERVICE_NAME:-${REPO}}"
        read -rp "Primary port [8080]: " _PORT
        PORT="${_PORT:-8080}"
        read -rp "Container registry [ghcr.io/${OWNER}]: " _REGISTRY
        REGISTRY="${_REGISTRY:-ghcr.io/${OWNER}}"
    else
        SERVICE_NAME="${REPO}"
        PORT="8080"
        REGISTRY="ghcr.io/${OWNER}"
    fi

    # --- Derived values ---
    PROJECT_UPPER=$(echo "$REPO" | tr '[:lower:]-' '[:upper:]_')
    PROJECT_LOWER=$(echo "$REPO" | tr '[:upper:]-' '[:lower:]_')
    CURRENT_YEAR=$(date +%Y)
    CURRENT_DATE=$(date +%Y-%m-%d)
    VERSION="0.1.0"

    # --- Derive the repo's uuid --------------------------------------------
    # THE UUID IS DERIVED, NOT ALLOCATED (gv-clade-index:
    # docs/SPEC-clade-verisim-portal.adoc §Identity Model):
    #     uuid = UUIDv5(namespace = URL, name = "github.com/<owner>/<name>")
    # We know OWNER and REPO, so this is computable here and must never be
    # guessed or copied. The owner segment is part of the derived name, so it is
    # part of the identity — a repo hosted elsewhere derives a different uuid.
    if command -v uuidgen >/dev/null 2>&1; then
        REPO_UUID=$(uuidgen --sha1 --namespace @url --name "${FORGE}/${OWNER}/${REPO}")
    else
        REPO_UUID="UNASSIGNED"
    fi

    # Derive citation name parts (best-effort split on last space)
    AUTHOR_LAST="${AUTHOR##* }"
    AUTHOR_FIRST="${AUTHOR% *}"
    FIRST_INITIAL="${AUTHOR_FIRST:0:1}."
    if [ "$AUTHOR_LAST" = "$AUTHOR_FIRST" ]; then
        AUTHOR_FIRST="$AUTHOR"
        AUTHOR_LAST=""
        FIRST_INITIAL=""
    fi

    echo ""
    echo "── Summary ──────────────────────────────────────"
    echo "  Project:     $PROJECT_NAME"
    echo "  Repo:        $REPO"
    echo "  Owner:       $OWNER"
    echo "  Author:      $AUTHOR <$AUTHOR_EMAIL>"
    [ -n "$AUTHOR_ORG" ] && echo "  Organization: $AUTHOR_ORG"
    echo "  Forge:       $FORGE"
    echo "  Year:        $CURRENT_YEAR"
    echo "────────────────────────────────────────────────"
    echo ""
    read -rp "Proceed? [Y/n] " CONFIRM
    [[ "${CONFIRM:-Y}" =~ ^[Nn] ]] && echo "Aborted." && exit 0

    echo ""
    echo "Replacing placeholders..."

    # Apply archetype overlay files (if any) BEFORE substitution, so overlay
    # files are rendered along with the rest of the tree.
    if [ -n "$ARCHETYPE" ] && [ -d "archetypes/${ARCHETYPE}/overlay" ]; then
        cp -a "archetypes/${ARCHETYPE}/overlay/." .
        echo "  applied overlay: archetypes/${ARCHETYPE}/overlay/"
    fi

    # Brace tokens as variables (hex avoids just interpolation)
    LB=$(printf '\x7b\x7b')
    RB=$(printf '\x7d\x7d')

    # Build the sed expression list
    # Note: using | as delimiter since URLs contain /
    SED_ARGS=(
        -e "s|${LB}PROJECT_NAME${RB}|${PROJECT_NAME}|g"
        -e "s|${LB}PROJECT_DESCRIPTION${RB}|${PROJECT_DESCRIPTION}|g"
        -e "s|${LB}PROJECT${RB}|${PROJECT_UPPER}|g"
        -e "s|${LB}project${RB}|${PROJECT_LOWER}|g"
        -e "s|${LB}REPO${RB}|${REPO}|g"
        -e "s|${LB}OWNER${RB}|${OWNER}|g"
        -e "s|${LB}AUTHOR${RB}|${AUTHOR}|g"
        -e "s|${LB}AUTHOR_EMAIL${RB}|${AUTHOR_EMAIL}|g"
        -e "s|${LB}AUTHOR_ORG${RB}|${AUTHOR_ORG}|g"
        -e "s|${LB}AUTHOR_LAST${RB}|${AUTHOR_LAST}|g"
        -e "s|${LB}AUTHOR_FIRST${RB}|${AUTHOR_FIRST}|g"
        -e "s|${LB}AUTHOR_INITIALS${RB}|${FIRST_INITIAL}|g"
        -e "s|${LB}FORGE${RB}|${FORGE}|g"
        -e "s|${LB}CURRENT_YEAR${RB}|${CURRENT_YEAR}|g"
        -e "s|${LB}CURRENT_DATE${RB}|${CURRENT_DATE}|g"
        -e "s|${LB}DATE${RB}|${CURRENT_DATE}|g"
        -e "s|${LB}SECURITY_EMAIL${RB}|${SECURITY_EMAIL}|g"
        -e "s|${LB}CONDUCT_EMAIL${RB}|${CONDUCT_EMAIL}|g"
        -e "s|${LB}LICENSE${RB}|MPL-2.0|g"
        -e "s|${LB}CONDUCT_TEAM${RB}|Code of Conduct Committee|g"
        -e "s|${LB}RESPONSE_TIME${RB}|48 hours|g"
        -e "s|${LB}MAIN_BRANCH${RB}|main|g"
        -e "s|${LB}PROJECT_PURPOSE${RB}|${PROJECT_DESCRIPTION}|g"
        -e "s|${LB}PROJECT_ROLE${RB}|${PROJECT_TYPE}|g"
        -e "s|${LB}PROJECT_TYPE${RB}|${PROJECT_TYPE}|g"
        -e "s|${LB}WEBSITE${RB}|${WEBSITE}|g"
        -e "s|${LB}SERVICE_NAME${RB}|${SERVICE_NAME}|g"
        -e "s|${LB}PORT${RB}|${PORT}|g"
        -e "s|${LB}REGISTRY${RB}|${REGISTRY}|g"
        -e "s|${LB}IMAGE${RB}|${REGISTRY}/${SERVICE_NAME}|g"
        -e "s|${LB}VERSION${RB}|${VERSION}|g"
        -e "s|${LB}EMAIL${RB}|${AUTHOR_EMAIL}|g"
        -e "s|${LB}UUID${RB}|${REPO_UUID}|g"
        -e "s|${LB}DESCRIPTION${RB}|${PROJECT_DESCRIPTION}|g"
    )
    [ -n "$AUTHOR_EMAIL_ALT" ] && SED_ARGS+=(-e "s|${LB}AUTHOR_EMAIL_ALT${RB}|${AUTHOR_EMAIL_ALT}|g")
    [ -n "$OPENSSF_BP_ID" ] && SED_ARGS+=(-e "s|${LB}OPENSSF_BP_ID${RB}|${OPENSSF_BP_ID}|g")
    [ -n "$OPENSSF_BP_ID" ] && SED_ARGS+=(-e "s|${LB}OPENSSF_PROJECT_ID${RB}|${OPENSSF_BP_ID}|g")

    # Archetype-determined tokens (ADR-0003): the archetype contract fills
    # what it can honestly determine. Added BEFORE the UNASSIGNED fallback
    # below — sed applies expressions in order, so a token the archetype
    # answers never reaches the fallback, and one it omits still fails loudly.
    if [ -n "$ARCH_FILE" ]; then
        while IFS= read -r arch_line; do
            arch_tok="${arch_line%%=*}"; arch_tok="${arch_tok// /}"
            arch_val=$(printf '%s' "$arch_line" | sed -n 's/^[^=]*= *"\(.*\)" *$/\1/p')
            { [ -n "$arch_tok" ] && [ -n "$arch_val" ]; } || continue
            case "$arch_val" in *'|'*)
                echo "WARN: archetype token $arch_tok contains '|' (the sed delimiter) — skipped, stays UNASSIGNED"
                continue ;;
            esac
            SED_ARGS+=(-e "s|${LB}${arch_tok}${RB}|${arch_val}|g")
        done < <(awk '$0=="[tokens]"{f=1;next} /^\[/{f=0} f && !/^[[:space:]]*#/ && NF' "$ARCH_FILE")
    fi

    # Tokens only the author can answer. init cannot know a project's unique
    # strength or its language stack, and guessing would write fiction into
    # ANCHOR.a2ml — the file the estate treats as semantic authority. They
    # become UNASSIGNED, the same marker `just init` already writes for an
    # unchosen clade: honest, greppable, and obviously unfinished, whereas a
    # leftover brace token just looks like the template broke.
    #   grep -rn UNASSIGNED . — to find what still needs you
    # (Brace tokens are spelled via ${LB}/${RB} throughout this recipe: just
    #  interpolates literal double braces even inside comments.)
    for tok in PROJECT_KIND PROJECT_DOMAIN PROJECT_UNIQUE_STRENGTH \
               TARGET_AUDIENCE LANG_STACK BUILD_CMD TEST_CMD MUST_INVARIANTS \
               PACKAGE_NAME DEPS BUILD_OUTPUT_PATH MAIN_FUNCTION; do
        SED_ARGS+=(-e "s|${LB}${tok}${RB}|UNASSIGNED|g")
    done

    # Optional values with no answer: drop the line that depends on them rather
    # than leaving the token in place. An unfilled token is not a neutral
    # reminder — the OpenSSF line renders a broken badge image and a dead link
    # in the new repo's README, and it trips the placeholder gate on every
    # subsequent push, which trains people to ignore a red CI. No id yet means
    # no badge yet; add it when you register at bestpractices.dev.
    if [ -z "$OPENSSF_BP_ID" ]; then
        sed -i "/bestpractices\.dev\/projects\/${LB}OPENSSF_BP_ID${RB}/d" README.adoc 2>/dev/null || true
        sed -i "/${LB}OPENSSF_PROJECT_ID${RB}/d" docs/governance/TEMPLATE-STANDARDS-AUDIT.adoc 2>/dev/null || true
    fi
    # A .mailmap exists to map an alternate address onto the canonical one.
    # With no alternate address there is nothing to map, and the sole entry
    # would keep an unfilled alt-email token in the angle brackets, which is a
    # malformed mailmap rather than a harmless leftover.
    if [ -z "$AUTHOR_EMAIL_ALT" ]; then
        printf '# No alternate author address to map.\n' > .github/.mailmap
    fi

    # Replace in all text files (skip .git, LICENSE text, and binaries)
    find . -type f \
        -not -path './.git/*' \
        -not -name 'MPL-2.0.txt' \
        -not -name '*.png' -not -name '*.jpg' -not -name '*.gif' \
        -not -name '*.woff' -not -name '*.woff2' \
        | while read -r file; do
        if file --brief "$file" | grep -qi 'text\|ascii\|utf'; then
            sed -i "${SED_ARGS[@]}" "$file"
        fi
    done

    # Also replace [YOUR-REPO-NAME] and [YOUR-NAME/ORG] in AI manifest
    sed -i "s|\[YOUR-REPO-NAME\]|${PROJECT_NAME}|g" 0-AI-MANIFEST.a2ml 2>/dev/null || true
    sed -i "s|\[YOUR-NAME/ORG\]|${OWNER}|g" 0-AI-MANIFEST.a2ml 2>/dev/null || true

    echo ""
    echo "── Identity (CLADE.a2ml) ────────────────────────"

    # Install THIS repo's CLADE.a2ml, replacing rsr-template-repo's own.
    #
    # The CLADE.a2ml shipped in the template is the TEMPLATE's real identity — a
    # real uuid for a real repo. Nothing in SED_ARGS ever touched it, so every
    # repo created from this template inherited uuid a5ea1382-… and
    # canonical-name "rsr-template-repo" verbatim, and told every arriving agent
    # it WAS the template. Nothing caught it: each value was individually valid.
    # chronicles-of-slavia and scaffoldia were corrected for exactly this on
    # 2026-07-16; paint-type, cargo-zigbuild, email-octad-experiment, llm-grace
    # and rsr-template-how-to still carry it.
    #
    # build/templates/CLADE.a2ml.in has already had its brace tokens filled by
    # the substitution loop above (including the UUID one, derived earlier).
    # NB: literal double-brace tokens cannot be written in this recipe body —
    # just interpolates them, which is why LB/RB are built with printf above.
    # The split is the whole point:
    #   DERIVABLE -> computed, never guessed  (uuid, owner, canonical-name)
    #   JUDGEMENT -> left UNASSIGNED, fails loudly until a human chooses (clade)
    CLADE_IN="build/templates/CLADE.a2ml.in"
    CLADE_OUT=".machine_readable/descriptiles/CLADE.a2ml"
    if [ -f "$CLADE_IN" ]; then
        mkdir -p "$(dirname "$CLADE_OUT")"
        cp "$CLADE_IN" "$CLADE_OUT"
        rm -rf build/templates          # template-only; not part of your repo
        if [ "$REPO_UUID" = "UNASSIGNED" ]; then
            echo "  uuid:  UNASSIGNED — uuidgen not found."
            echo "         Install util-linux (uuid-runtime), then run:"
            echo "           uuidgen --sha1 --namespace @url --name \"${FORGE}/${OWNER}/${REPO}\""
            echo "         and put the result in $CLADE_OUT."
        else
            echo "  uuid:  $REPO_UUID"
            echo "         (uuid5 of ${FORGE}/${OWNER}/${REPO} — derived, recomputable, not invented)"
        fi
        echo "  clade: UNASSIGNED — a human must choose one of the 12."
        echo "         CLADE-003/006 FAIL until you do. That is deliberate:"
        echo "         an unchosen clade must not look like a chosen one."
        echo "         The taxonomy is listed in $CLADE_OUT."
    fi

    echo ""
    echo "── Profile & provenance (ADR-0003) ──────────────"

    # The template's own rsr-profile.a2ml is deliberately MAXIMAL (it is the
    # dogfood target). A minted repo must NOT inherit it: declaring
    # capabilities the tree lacks makes the oracle score modules that are
    # absent (na-honesty, RSR-SPEC-v2 §scoring). Rewrite it minimally.
    PROFILE_OUT=".machine_readable/rsr-profile.a2ml"
    {
        echo "# SPDX-License-Identifier: MPL-2.0"
        echo "#"
        echo "# rsr-profile.a2ml — this repo's declared RSR v2.0 capabilities."
        echo "# Generated by just init on ${CURRENT_DATE}. The template's maximal"
        echo "# profile was removed at mint: declare only what this tree carries."
        echo ""
        echo "[rsr-profile]"
        echo "version = \"1.0.0\""
        echo "spec = \"rsr-criteria-v2\""
        echo "declares-against = \"2.0.0-draft\""
        if [ -n "$ARCH_PRESET" ]; then
            echo "preset = \"${ARCH_PRESET}\""
        else
            echo "# UNASSIGNED: declare capabilities (or a preset) — see standards"
            echo "# .machine_readable/template-capability-gates.toml"
            echo "capabilities = []"
        fi
    } > "$PROFILE_OUT"
    echo "  profile:    $PROFILE_OUT${ARCH_PRESET:+  (preset $ARCH_PRESET)}"

    # Provenance — the estate's answer-file (ADR-0002 contract shape, used
    # per ADR-0003 with direction=generated-from-core). parent-pin resolves
    # from the live template tip: correct for a fresh mint, UNASSIGNED when
    # offline — honest, never guessed.
    PARENT_SLUG="hyperpolymath/rsr-template-repo"
    PARENT_PIN=$(git ls-remote "https://github.com/${PARENT_SLUG}.git" HEAD 2>/dev/null | cut -f1 || true)
    PARENT_PIN="${PARENT_PIN:-UNASSIGNED}"
    VARIANT_OUT=".machine_readable/descriptiles/VARIANT.a2ml"
    mkdir -p "$(dirname "$VARIANT_OUT")"
    {
        echo "# SPDX-License-Identifier: MPL-2.0"
        echo "#"
        echo "# VARIANT.a2ml — provenance contract (ADR-0002 shape; ADR-0003 use)."
        echo "# Records what this repo was minted from so the drift gate"
        echo "# (scripts/check-variant-drift.sh <parent-checkout>) and future"
        echo "# re-templating tooling have a defined input."
        echo "#"
        echo "# NOTE: placeholder rendering means many files differ from the"
        echo "# parent by design; folding rendered answers into [normalise] is"
        echo "# future work (ADR-0003), so the gate is informational for minted"
        echo "# repos until then."
        echo ""
        echo "[metadata]"
        echo "project = \"${REPO}\""
        echo "schema_version = \"0.1.0\""
        echo "last-updated = \"${CURRENT_DATE}\""
        echo ""
        echo "[variant]"
        echo "parent = \"${PARENT_SLUG}\""
        echo "parent-pin = \"${PARENT_PIN}\"  # template tip at mint"
        echo "role = \"minted-repo\""
        echo "stack = \"${ARCHETYPE:-unspecified}\""
        echo "direction = \"generated-from-core\""
        echo ""
        echo "[normalise]"
        echo "rules = \"action-pins self-name\""
        echo ""
        echo "[paths.added]"
        echo "paths = []"
        echo ""
        echo "[paths.removed]"
        echo "paths = []"
        echo ""
        echo "[paths.diverged]"
        echo "# Files a minted repo owns from birth."
        echo "paths = ["
        echo "  \".machine_readable/descriptiles/CLADE.a2ml\","
        echo "  \".machine_readable/descriptiles/VARIANT.a2ml\","
        echo "  \".machine_readable/rsr-profile.a2ml\","
        echo "]"
    } > "$VARIANT_OUT"
    if [ "$PARENT_PIN" = "UNASSIGNED" ]; then
        echo "  provenance: $VARIANT_OUT — parent-pin UNASSIGNED (offline?)"
        echo "              Set it to the template commit you minted from:"
        echo "              git ls-remote https://github.com/${PARENT_SLUG}.git HEAD"
    else
        echo "  provenance: $VARIANT_OUT  (parent-pin ${PARENT_PIN:0:12})"
    fi

    # archetypes/ is template-only overlay data, not part of your repo
    # (same reason build/templates is removed above).
    rm -rf archetypes

    echo ""
    echo "── Validation ───────────────────────────────────"

    # Check for remaining placeholders
    PATTERN="${LB}[A-Z_]*${RB}"
    REMAINING=$(grep -rl "$PATTERN" . --include='*.md' --include='*.adoc' --include='*.yml' --include='*.yaml' --include='*.a2ml' --include='*.toml' --include='*.scm' --include='*.ncl' --include='*.nix' --include='*.json' --include='*.sh' 2>/dev/null | grep -v '.git/' | grep -v '.machine_readable/ai/PLACEHOLDERS.adoc' || true)
    if [ -n "$REMAINING" ]; then
        echo "WARNING: Remaining placeholders in:"
        echo "$REMAINING" | sed 's/^/  /'
        echo ""
        echo "Run: grep -rn '$LB' . --include='*.md' to inspect"
    else
        echo "All placeholders replaced successfully!"
    fi

    # K9-SVC validation (if available)
    if command -v k9-svc >/dev/null 2>&1; then
        echo ""
        echo "Running k9-svc validation..."
        k9-svc validate . 2>/dev/null || true
    fi

    echo ""
    echo "Running OpenSSF compliance verification..."
    just verify

    echo ""
    echo "Done! Mint complete. Remaining Forge stages (ADR-0003):"
    echo "  1. Review changes: git diff"
    echo "  2. Remove template cruft: rm .machine_readable/ai/PLACEHOLDERS.adoc"
    echo "  3. Customize README.adoc; then: grep -rn UNASSIGNED . for what still needs you"
    echo "  4. PROVISION — actually run your build and test commands and watch"
    echo "     them pass (echoed advice is not provisioning)."
    echo "  5. Commit: git add -A && git commit -m 'feat: initialize from RSR template'"
    echo "  6. Push: git remote add origin git@${FORGE}:${OWNER}/${REPO}.git && git push -u origin main"
    echo "  7. CONFIGURE — out of band, once (this recipe runs no gh commands):"
    echo "       gh repo edit ${OWNER}/${REPO} --description '<one line>' --homepage '${WEBSITE}'"
    echo "     Visibility is fail-closed private; flip deliberately if wanted:"
    echo "       gh repo edit ${OWNER}/${REPO} --visibility public --accept-visibility-change-consequences"
    echo "     Register in gv-clade-index; required contexts must equal emitted job ids."
    echo "  8. HARNESS — arm the drift gate against your recorded parent-pin:"
    echo "       scripts/check-variant-drift.sh <parent-checkout-dir>"
