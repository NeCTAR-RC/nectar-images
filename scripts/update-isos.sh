#!/usr/bin/env bash
# shellcheck disable=SC2086,SC2329

set -o errexit
set -o nounset
set -o pipefail

## Colours
all_off="$(tput sgr0)"
bold="${all_off}$(tput bold)"
black="${bold}$(tput setaf 0)"
green="${bold}$(tput setaf 2)"
blue="${bold}$(tput setaf 4)"

DEBUG=1

# Message helpers
msg() {
    printf "%s\n" "$1"
}
debug() {
    [[ -n ${DEBUG:-} ]] && printf "%s:: %s%s\n" "${black}" "$1" "${all_off}"
}
info() {
    printf "%s::%s %s%s\n" "${blue}" "${bold}" "$1" "${all_off}"
}
action() {
    printf "%s==>%s %s%s\n" "${green}" "${bold}" "$1" "${all_off}"
}

git_diff() {
    export GIT_CONFIG_GLOBAL=''
    export GIT_CONFIG_SYSTEM=''
    git diff -U0 --color=always "$1" # | grep --color=never -E $'^\e\[(32m\+|31m-)' || true
}

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
VARS_DIR="$BASE_DIR/../vars"
MIRROR="http://mirror.aarnet.edu.au/pub"
DEBIAN_ARCHIVE="https://cdimage.debian.org/mirror/cdimage/archive"

# Print the value of an HCL "key = "value"" assignment from a vars file.
field() {  # key file
    sed -n 's/^'"$1"' *= *"\(.*\)"/\1/p' "$2"
}

# Parse "SHA256 (filename) = hash" lines (matching $1) into "filename hash".
parse_sha256() {  # grep_pattern  (reads checksum content on stdin)
    grep -E "$1" | sed -n 's/^SHA256 (\(.*\)) = \([[:alnum:]]\+\)$/\1 \2/p'
}

# True when $details holds both a filename and a hash, i.e. the lookup worked.
# Lets callers skip versions whose ISO isn't on the mirror (archived/unreleased).
resolved() {
    if [[ ${#details[@]} -lt 2 ]]; then
        msg "  could not resolve ISO from mirror, skipping"
        return 1
    fi
}

# Print the iso-cd URL hosting a given Debian major release. The current stable
# lives under .../current; older releases come from the archive, which keeps a
# directory per point release (e.g. 11.11.0). Prints nothing if not found.
debian_iso_dir() {  # major_ver
    local ver=$1 current="$MIRROR/debian-cd/current/amd64/iso-cd" point
    if curl -s -L "$current/SHA256SUMS" | grep -q "debian-$ver\."; then
        printf '%s\n' "$current"
        return
    fi
    # newest "<ver>.x.y" point release (the regex skips -live / unreleased dirs)
    point=$(curl -s -L "$DEBIAN_ARCHIVE/" \
        | sed -n 's#.*<a href="\('"$ver"'\.[0-9][0-9.]*\)/".*#\1#p' | sort -V | tail -n1)
    [[ -n $point ]] && printf '%s\n' "$DEBIAN_ARCHIVE/$point/amd64/iso-cd"
}

# Resolve the latest ISO for an OS, setting $iso_url and $iso_checksum.
# Returns non-zero (and explains) when the OS is unsupported or the lookup fails.
resolve_iso() {  # os_name os_version os_arch
    local name=$1 ver=$2 arch=$3 base_url checksum_file
    case $name in
        almalinux|rocky)  # boot.iso in CHECKSUM, ignoring the "latest" alias
            base_url="$MIRROR/$name/$ver/isos/$arch"
            IFS=" " read -ra details <<< "$(curl -s -L "$base_url/CHECKSUM" | parse_sha256 'SHA256.*boot.iso' | grep -v latest)"
            resolved || return 1
            iso_url="$base_url/${details[0]}"; iso_checksum="sha256:${details[1]}" ;;
        centos-stream)  # filename contains "latest", so it is kept, not filtered
            base_url="$MIRROR/centos-stream/$ver-stream/BaseOS/$arch/iso"
            IFS=" " read -ra details <<< "$(curl -s -L "$base_url/SHA256SUM" | parse_sha256 'SHA256.*boot.iso')"
            resolved || return 1
            iso_url="$base_url/${details[0]}"; iso_checksum="sha256:${details[1]}" ;;
        debian)  # "hash  filename"; older releases come from the archive
            base_url=$(debian_iso_dir "$ver")
            [[ -n $base_url ]] || { msg "  no ISO directory found, skipping"; return 1; }
            IFS=" " read -ra details <<< "$(curl -s -L "$base_url/SHA256SUMS" | grep -E "debian-$ver\..*netinst")"
            resolved || return 1
            iso_url="$base_url/${details[1]}"; iso_checksum="sha256:${details[0]}" ;;
        fedora)  # locate the CHECKSUM file from the release listing, then parse it
            base_url="$MIRROR/fedora/linux/releases/$ver/Server/$arch/iso"
            checksum_file=$(curl -s -L "$base_url" | grep CHECKSUM | sed -n 's#^.*<a href="\(Fedora-Server-'"$ver"'.*\)">Fedora-Server-'"$ver"'.*</a>.*$#\1#p')
            IFS=" " read -ra details <<< "$(curl -s "$base_url/$checksum_file" | parse_sha256 'SHA256.*Fedora-Server-netinst')"
            resolved || return 1
            iso_url="$base_url/${details[0]}"; iso_checksum="sha256:${details[1]}" ;;
        ubuntu)  # "hash *filename"
            base_url="$MIRROR/ubuntu/releases/$ver"
            IFS=" " read -ra details <<< "$(curl -s -L "$base_url/SHA256SUMS" | grep -E 'live-server')"
            resolved || return 1
            iso_url="$base_url/${details[1]#\*}"; iso_checksum="sha256:${details[0]}" ;;
        *)
            msg "  no ISO resolver for '$name', skipping"; return 1 ;;
    esac
}

# Write $iso_url and $iso_checksum into $var_file and show the diff.
write_vars() {
    debug "url: $iso_url"
    debug "checksum: $iso_checksum"
    sed -i 's,\(iso_url\s\+=\).*$,\1 "'$iso_url'",g' "$var_file"
    sed -i 's,\(iso_checksum\s\+=\).*$,\1 "'$iso_checksum'",g' "$var_file"
    git_diff "$var_file"
}

# Update every ISO-based vars file, keyed off the os_name/os_version/os_arch it
# declares. Files without an iso_url build from a cloud image and are left alone.
# Lookups are memoised so OSes shared by many variants are fetched only once.
declare -A iso_cache
for var_file in "$VARS_DIR"/*.pkrvars.hcl; do
    grep -q '^iso_url' "$var_file" || continue
    os_name=$(field os_name "$var_file")
    os_version=$(field os_version "$var_file")
    os_arch=$(field os_arch "$var_file")
    action "Checking ${var_file##*/} ($os_name $os_version $os_arch)"

    key="$os_name $os_version $os_arch"
    if [[ -n ${iso_cache[$key]:-} ]]; then
        iso_url=${iso_cache[$key]%%|*}
        iso_checksum=${iso_cache[$key]#*|}
    elif resolve_iso "$os_name" "$os_version" "$os_arch"; then
        iso_cache[$key]="$iso_url|$iso_checksum"
    else
        continue
    fi
    write_vars
done
