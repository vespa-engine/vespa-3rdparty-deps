#!/usr/bin/env bash
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
#
# Bump vespa-otelcol to the latest OpenTelemetry Collector release.
#
# Usage: scripts/bump-otelcol-version.sh [-n] [CORE_VERSION [CONTRIB_VERSION]]
#   -n               Dry run: only report what would change.
#   CORE_VERSION     opentelemetry-collector version (e.g. 0.165.0). Defaults
#                    to the latest release of the collector builder.
#   CONTRIB_VERSION  opentelemetry-collector-contrib version (e.g. 0.165.1).
#                    Defaults to the latest contrib release.
#
# Core and contrib share major.minor but may have separate patch releases.
# The core version becomes the rpm version (MAJOR/MINOR/PATCH in
# otelcol/.copr/Makefile) and is used for the builder and the
# go.opentelemetry.io/collector modules. The contrib version is
# CONTRIB_VERSION in the Makefile and is used for the
# opentelemetry-collector-contrib modules in builder-config.yaml.
#
# Modules in otelcol/builder-config.yaml that no longer exist at the new
# version are handled using the REPLACEMENTS table below (replaced by their
# upstream successor, or removed). Any other missing module aborts the
# upgrade without changing anything.
#
# On success the patch level of dist.version in builder-config.yaml is
# bumped and an entry is added to %changelog in the spec template.

set -euo pipefail

dry_run=false
if [[ "${1:-}" == "-n" ]]; then
    dry_run=true
    shift
fi

if [[ $# -gt 2 ]]; then
    echo "Usage: $0 [-n] [CORE_VERSION [CONTRIB_VERSION]]" >&2
    exit 1
fi

top=$(cd "$(dirname "$0")/.." && pwd)
pkgdir="$top/otelcol"
makefile="$pkgdir/.copr/Makefile"
config="$pkgdir/builder-config.yaml"
spec="$pkgdir/vespa-otelcol.spec.tmpl"

goproxy=https://proxy.golang.org
core_mod=go.opentelemetry.io/collector
contrib_mod=github.com/open-telemetry/opentelemetry-collector-contrib

# Known modules removed upstream: "old-module new-module", where new-module
# "-" means remove it without a replacement.
REPLACEMENTS=(
    # Removed in core v0.111.0, superseded by the debug exporter.
    "$core_mod/exporter/loggingexporter $core_mod/exporter/debugexporter"
    # Removed in contrib v0.131.0. Loki ingests OTLP natively; use the
    # otlphttp exporter instead.
    "$contrib_mod/exporter/lokiexporter -"
)

replacement_for() {
    local entry
    for entry in "${REPLACEMENTS[@]}"; do
        if [[ "${entry%% *}" == "$1" ]]; then
            echo "${entry#* }"
            return 0
        fi
    done
    return 1
}

# Print the latest version (without leading 'v') of a Go module.
latest_module_version() {
    curl -fsSL "$goproxy/$1/@latest" | sed -n 's/.*"Version":"v\([^"]*\)".*/\1/p'
}

# Succeeds if module $1 exists at version $2 (without leading 'v').
module_version_exists() {
    curl -fsS -o /dev/null "$goproxy/$1/@v/v$2.info" 2>/dev/null
}

core=${1:-$(latest_module_version "$core_mod/cmd/builder")}
core=${core#v}
if [[ $# -ge 2 ]]; then
    contrib=${2#v}
else
    contrib=$(curl -fsSL https://api.github.com/repos/open-telemetry/opentelemetry-collector-contrib/releases/latest |
              sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p')
fi

for v in "$core" "$contrib"; do
    if ! [[ "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Invalid version: '$v'" >&2
        exit 1
    fi
done

if [[ "${core%.*}" != "${contrib%.*}" ]]; then
    echo "Core version $core and contrib version $contrib differ in major.minor." >&2
    echo "Pass both versions explicitly to choose a matching pair." >&2
    exit 1
fi

get_var() {
    sed -n "s/^$1=\(.*\)\$/\1/p" "$makefile"
}

old_core="$(get_var MAJOR).$(get_var MINOR).$(get_var PATCH)"
old_contrib=$(get_var CONTRIB_VERSION)
old_release=$(get_var RELEASE)

echo "Core:    $old_core -> $core"
echo "Contrib: $old_contrib -> $contrib"

if [[ "$old_core" == "$core" && "$old_contrib" == "$contrib" ]]; then
    echo "otelcol is already at the latest version."
    exit 0
fi

# Work on a copy of the config so nothing changes unless everything checks out.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
new_config="$tmpdir/builder-config.yaml"
cp "$config" "$new_config"

# Verify that the builder, source tarball and all modules exist at the new version.
missing=()
module_version_exists "$core_mod/cmd/builder" "$core" || missing+=("$core_mod/cmd/builder v$core")
curl -fsSI -o /dev/null "https://github.com/open-telemetry/opentelemetry-collector/archive/refs/tags/v$core.tar.gz" ||
    missing+=("opentelemetry-collector source tarball v$core")

config_changes=()
while read -r mod placeholder; do
    case "$placeholder" in
        vCONTRIB_VERSION) ver=$contrib ;;
        vVERSION)         ver=$core ;;
        *) echo "  skip     $mod $placeholder (no version placeholder)"; continue ;;
    esac
    if module_version_exists "$mod" "$ver"; then
        echo "  ok       $mod v$ver"
        continue
    fi
    if repl=$(replacement_for "$mod"); then
        if [[ "$repl" == "-" ]]; then
            echo "  REMOVE   $mod (no longer released)"
            perl -ni -e "print unless m{^\\s*- gomod: \"\\Q$mod\\E }" "$new_config"
            config_changes+=("removed $mod")
        elif module_version_exists "$repl" "$ver"; then
            echo "  REPLACE  $mod -> $repl v$ver"
            perl -pi -e "s{\"\\Q$mod\\E }{\"$repl }" "$new_config"
            config_changes+=("replaced $mod with $repl")
        else
            echo "  MISSING  $mod v$ver (replacement $repl v$ver not found either)"
            missing+=("$repl v$ver")
        fi
        continue
    fi
    latest=$(latest_module_version "$mod" || true)
    echo "  MISSING  $mod v$ver (latest: ${latest:-none})"
    missing+=("$mod v$ver")
done < <(sed -n 's/^ *- gomod: *"\([^"]*\)".*/\1/p' "$config")

if [[ ${#missing[@]} -gt 0 ]]; then
    echo >&2
    echo "The following are not available at the new version:" >&2
    printf '  %s\n' "${missing[@]}" >&2
    echo "Add them to REPLACEMENTS in $0, or edit $config, and rerun. No changes made." >&2
    exit 1
fi

if $dry_run; then
    echo "Dry run: would update otelcol to $core (contrib $contrib)"
    diff -u "$config" "$new_config" || true
    exit 0
fi

IFS=. read -r major minor patch <<< "$core"
if [[ "$old_core" == "$core" ]]; then
    # Only contrib changed; rpm version is unchanged so bump release.
    release=$((old_release + 1))
else
    release=1
fi

perl -pi -e "
    s/^MAJOR=.*/MAJOR=$major/;
    s/^MINOR=.*/MINOR=$minor/;
    s/^PATCH=.*/PATCH=$patch/;
    s/^RELEASE=.*/RELEASE=$release/;
    s/^CONTRIB_VERSION=.*/CONTRIB_VERSION=$contrib/;
" "$makefile"

# Bump the patch level of the distribution version (dist.version).
perl -pi -e 's/^(\s*version:\s*"\d+\.\d+\.)(\d+)"/$1 . ($2 + 1) . "\""/e' "$new_config"
cp "$new_config" "$config"

# Add a changelog entry to the spec.
author="$(git -C "$top" config user.name || echo unknown) <$(git -C "$top" config user.email || echo unknown)>"
entry_ver=$core
[[ "$release" -gt 1 ]] && entry_ver="$core-$release"
entry_msg="Bump version to $core"
[[ "$contrib" != "$core" ]] && entry_msg="$entry_msg (contrib $contrib)"
CHANGELOG_ENTRY="* $(LC_ALL=C date '+%a %b %d %Y') $author - $entry_ver
- $entry_msg" perl -0pi -e 's/^%changelog\n/%changelog\n$ENV{CHANGELOG_ENTRY}\n/m' "$spec"

echo "Updated otelcol to $core (contrib $contrib), RELEASE=$release"
if [[ ${#config_changes[@]} -gt 0 ]]; then
    echo
    echo "NOTE: builder-config.yaml changed; collector configs using these components must be updated:"
    printf '  %s\n' "${config_changes[@]}"
fi
