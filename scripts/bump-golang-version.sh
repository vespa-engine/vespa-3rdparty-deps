#!/usr/bin/env bash
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
#
# Bump the Go compiler version used to build all packages to the latest
# stable Go release, and bump RELEASE in .copr/Makefile for every package
# where the compiler version changed.
#
# Usage: scripts/bump-golang-version.sh [-n] [GO_VERSION]
#   -n          Dry run: only report what would change.
#   GO_VERSION  Version to use (e.g. 1.27.4). Defaults to the latest stable
#               release reported by https://go.dev/VERSION?m=text.
#
# Recognized version references in a package directory:
#   %define|%global go_version X.Y.Z (rpm spec templates)
#   goX.Y.Z                          (e.g. golang.org/dl/goX.Y.Z, goX.Y.Z download,
#                                     go: "goX.Y.Z" in builder-config.yaml)

set -euo pipefail

dry_run=false
if [[ "${1:-}" == "-n" ]]; then
    dry_run=true
    shift
fi

if [[ $# -gt 1 ]]; then
    echo "Usage: $0 [-n] [GO_VERSION]" >&2
    exit 1
fi

if [[ $# -eq 1 ]]; then
    latest="${1#go}"
else
    latest=$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -n 1)
    latest="${latest#go}"
fi

if ! [[ "$latest" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Invalid Go version: '$latest'" >&2
    exit 1
fi

echo "Target Go version: $latest"

top=$(cd "$(dirname "$0")/.." && pwd)
cd "$top"

# Regex matching a Go version reference (perl syntax). Group 1 is the prefix
# to keep, group 2 is the version number.
go_ref_re='(%(?:define|global)\s+go_version\s+|\bgo)(\d+\.\d+(?:\.\d+)?)\b'

changed_pkgs=()

for makefile in */.copr/Makefile; do
    pkg=$(dirname "$(dirname "$makefile")")

    # Find files in the package referencing a Go compiler version.
    files=()
    while IFS= read -r f; do
        files+=("$f")
    done < <(find "$pkg" -path "$pkg/.copr" -prune -o -type f \
                  \( -name '*.spec.tmpl' -o -name '*.yaml' -o -name '*.yml' \) -print |
             xargs perl -ne "print \"\$ARGV\n\" if /$go_ref_re/; close ARGV if eof" 2>/dev/null |
             sort -u)

    [[ ${#files[@]} -eq 0 ]] && continue

    old_versions=$(perl -ne "print \"\$2\n\" while /$go_ref_re/g" "${files[@]}" | sort -u)
    outdated=$(grep -vxF "$latest" <<< "$old_versions" || true)
    if [[ -z "$outdated" ]]; then
        echo "$pkg: already using Go $latest"
        continue
    fi

    echo "$pkg: Go $(tr '\n' ' ' <<< "$outdated")-> $latest (${files[*]})"
    changed_pkgs+=("$pkg")
    $dry_run && continue

    perl -pi -e "s/$go_ref_re/\${1}$latest/g" "${files[@]}"

    old_release=$(sed -n 's/^RELEASE=\([0-9][0-9]*\)$/\1/p' "$makefile")
    if [[ -z "$old_release" ]]; then
        echo "$pkg: could not find RELEASE in $makefile" >&2
        exit 1
    fi
    new_release=$((old_release + 1))
    perl -pi -e "s/^RELEASE=\d+\$/RELEASE=$new_release/" "$makefile"
    echo "$pkg: RELEASE $old_release -> $new_release"
done

if [[ ${#changed_pkgs[@]} -eq 0 ]]; then
    echo "No packages needed updating."
elif $dry_run; then
    echo "Dry run: would update ${changed_pkgs[*]}"
else
    echo "Updated: ${changed_pkgs[*]}"
fi
