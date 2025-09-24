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

# AlmaLinux 8
distro=almalinux
ver=8
action "Checking $distro $ver"
var_file="$VARS_DIR/$distro-$ver.pkrvars.hcl"
base_url="http://mirror.aarnet.edu.au/pub/almalinux/8/isos/x86_64"
details=$(curl -s -L "$base_url/CHECKSUM" | grep -E 'SHA256.*boot.iso' | grep -v latest | sed -n 's/^SHA256 (\(.*\)) = \([[:alnum:]]\+\)$/\1 \2/p')
IFS=" " read -ra details <<< "$details"
iso_url="$base_url/${details[0]}"
iso_checksum="sha256:${details[1]}"
debug "url: $iso_url"
debug "checksum: $iso_checksum"
sed -i 's,\(iso_url\s\+=\).*$,\1 "'$iso_url'",g' $var_file
sed -i 's,\(iso_checksum\s\+=\).*$,\1 "'$iso_checksum'",g' $var_file
git_diff $var_file

# AlmaLinux 9
distro=almalinux
ver=9
action "Checking $distro $ver"
var_file="$VARS_DIR/$distro-$ver.pkrvars.hcl"
base_url="http://mirror.aarnet.edu.au/pub/almalinux/9/isos/x86_64"
output=$(curl -s -L "$base_url/CHECKSUM" | grep -E 'SHA256.*boot.iso' | grep -v latest | sed -n 's/^SHA256 (\(.*\)) = \([[:alnum:]]\+\)$/\1 \2/p')
IFS=" " read -ra details <<< "$output"
iso_url="$base_url/${details[0]}"
iso_checksum="sha256:${details[1]}"
debug "url: $iso_url"
debug "checksum: $iso_checksum"
sed -i 's,\(iso_url\s\+=\).*$,\1 "'$iso_url'",g' $var_file
sed -i 's,\(iso_checksum\s\+=\).*$,\1 "'$iso_checksum'",g' $var_file
git_diff $var_file

# AlmaLinux 10
distro=almalinux
ver=10
action "Checking $distro $ver"
var_file="$VARS_DIR/$distro-$ver.pkrvars.hcl"
base_url="http://mirror.aarnet.edu.au/pub/$distro/$ver/isos/x86_64"
output=$(curl -s -L "$base_url/CHECKSUM" | grep -E 'SHA256.*boot.iso' | grep -v latest | sed -n 's/^SHA256 (\(.*\)) = \([[:alnum:]]\+\)$/\1 \2/p')
IFS=" " read -ra details <<< "$output"
iso_url="$base_url/${details[0]}"
iso_checksum="sha256:${details[1]}"
debug "url: $iso_url"
debug "checksum: $iso_checksum"
sed -i 's,\(iso_url\s\+=\).*$,\1 "'$iso_url'",g' $var_file
sed -i 's,\(iso_checksum\s\+=\).*$,\1 "'$iso_checksum'",g' $var_file
git_diff $var_file

# CentOS Stream 9
distro=centos-stream
ver=9
action "Checking $distro $ver"
var_file="$VARS_DIR/$distro-$ver.pkrvars.hcl"
base_url="http://mirror.aarnet.edu.au/pub/centos-stream/9-stream/BaseOS/x86_64/iso"
output=$(curl -s -L "$base_url/SHA256SUM" | grep -E 'SHA256.*boot.iso' | sed -n 's/^SHA256 (\(.*\)) = \([[:alnum:]]\+\)$/\1 \2/p')
IFS=" " read -ra details <<< "$output"
iso_url="$base_url/${details[0]}"
iso_checksum="sha256:${details[1]}"
debug "url: $iso_url"
debug "checksum: $iso_checksum"
sed -i 's,\(iso_url\s\+=\).*$,\1 "'$iso_url'",g' $var_file
sed -i 's,\(iso_checksum\s\+=\).*$,\1 "'$iso_checksum'",g' $var_file
git_diff $var_file

# Debian 11
# TODO(andy) It's complicated as the old release is from the debian archive

# Debian 12
distro=debian
ver=12
action "Checking $distro $ver"
var_file="$VARS_DIR/$distro-$ver.pkrvars.hcl"
base_url="http://mirror.aarnet.edu.au/pub/debian-cd/current/amd64/iso-cd"
output=$(curl -s -L "$base_url/SHA256SUMS" | grep -E 'debian-12')
IFS=" " read -ra details <<< "$output"
iso_url="$base_url/${details[1]}"
iso_checksum="sha256:${details[0]}"
debug "url: $iso_url"
debug "checksum: $iso_checksum"
sed -i 's,\(iso_url\s\+=\).*$,\1 "'$iso_url'",g' $var_file
sed -i 's,\(iso_checksum\s\+=\).*$,\1 "'$iso_checksum'",g' $var_file
git_diff $var_file

# Fedora 41
distro=fedora
ver=41
action "Checking $distro $ver"
var_file="$VARS_DIR/$distro-$ver.pkrvars.hcl"
base_url="http://mirror.aarnet.edu.au/pub/fedora/linux/releases/$ver/Server/x86_64/iso"
checksum_file=$(curl -s -L $base_url | grep CHECKSUM | sed -n 's#^.*<a href="\(Fedora-Server-'$ver'.*\)">Fedora-Server-'$ver'.*</a>.*$#\1#p')
output=$(curl -s "$base_url/$checksum_file" | grep -E 'SHA256.*Fedora-Server-netinst' | sed -n 's/^SHA256 (\(.*\)) = \([[:alnum:]]\+\)$/\1 \2/p')
IFS=" " read -ra details <<< "$output"
iso_url="$base_url/${details[0]}"
iso_checksum="sha256:${details[1]}"
debug "url: $iso_url"
debug "checksum: $iso_checksum"
sed -i 's,\(iso_url\s\+=\).*$,\1 "'$iso_url'",g' $var_file
sed -i 's,\(iso_checksum\s\+=\).*$,\1 "'$iso_checksum'",g' $var_file
git_diff $var_file

# Fedora 422
distro=fedora
ver=42
action "Checking $distro $ver"
var_file="$VARS_DIR/$distro-$ver.pkrvars.hcl"
base_url="http://mirror.aarnet.edu.au/pub/fedora/linux/releases/$ver/Server/x86_64/iso"
checksum_file=$(curl -s -L $base_url | grep CHECKSUM | sed -n 's#^.*<a href="\(Fedora-Server-'$ver'.*\)">Fedora-Server-'$ver'.*</a>.*$#\1#p')
output=$(curl -s "$base_url/$checksum_file" | grep -E 'SHA256.*Fedora-Server-netinst' | sed -n 's/^SHA256 (\(.*\)) = \([[:alnum:]]\+\)$/\1 \2/p')
IFS=" " read -ra details <<< "$output"
iso_url="$base_url/${details[0]}"
iso_checksum="sha256:${details[1]}"
debug "url: $iso_url"
debug "checksum: $iso_checksum"
sed -i 's,\(iso_url\s\+=\).*$,\1 "'$iso_url'",g' $var_file
sed -i 's,\(iso_checksum\s\+=\).*$,\1 "'$iso_checksum'",g' $var_file
git_diff $var_file

# Rocky 8
distro=rocky
ver=8
action "Checking $distro $ver"
var_file="$VARS_DIR/$distro-$ver.pkrvars.hcl"
base_url="http://mirror.aarnet.edu.au/pub/$distro/8/isos/x86_64"
output=$(curl -s -L "$base_url/CHECKSUM" | grep -E 'SHA256.*boot.iso' | grep -v latest | sed -n 's/^SHA256 (\(.*\)) = \([[:alnum:]]\+\)$/\1 \2/p')
IFS=" " read -ra details <<< "$output"
iso_url="$base_url/${details[0]}"
iso_checksum="sha256:${details[1]}"
debug "url: $iso_url"
debug "checksum: $iso_checksum"
sed -i 's,\(iso_url\s\+=\).*$,\1 "'$iso_url'",g' $var_file
sed -i 's,\(iso_checksum\s\+=\).*$,\1 "'$iso_checksum'",g' $var_file
git_diff $var_file


# Rocky 9
distro=rocky
ver=9
action "Checking $distro $ver"
var_file="$VARS_DIR/$distro-$ver.pkrvars.hcl"
base_url="http://mirror.aarnet.edu.au/pub/$distro/9/isos/x86_64"
output=$(curl -s -L "$base_url/CHECKSUM" | grep -E 'SHA256.*boot.iso' | grep -v latest | sed -n 's/^SHA256 (\(.*\)) = \([[:alnum:]]\+\)$/\1 \2/p')
IFS=" " read -ra details <<< "$output"
iso_url="$base_url/${details[0]}"
iso_checksum="sha256:${details[1]}"
debug "url: $iso_url"
debug "checksum: $iso_checksum"
sed -i 's,\(iso_url\s\+=\).*$,\1 "'$iso_url'",g' $var_file
sed -i 's,\(iso_checksum\s\+=\).*$,\1 "'$iso_checksum'",g' $var_file
git_diff $var_file

# Rocky 10
distro=rocky
ver=10
action "Checking $distro $ver"
var_file="$VARS_DIR/$distro-$ver.pkrvars.hcl"
base_url="http://mirror.aarnet.edu.au/pub/$distro/$ver/isos/x86_64"
output=$(curl -s -L "$base_url/CHECKSUM" | grep -E 'SHA256.*boot.iso' | grep -v latest | sed -n 's/^SHA256 (\(.*\)) = \([[:alnum:]]\+\)$/\1 \2/p')
IFS=" " read -ra details <<< "$output"
iso_url="$base_url/${details[0]}"
iso_checksum="sha256:${details[1]}"
debug "url: $iso_url"
debug "checksum: $iso_checksum"
sed -i 's,\(iso_url\s\+=\).*$,\1 "'$iso_url'",g' $var_file
sed -i 's,\(iso_checksum\s\+=\).*$,\1 "'$iso_checksum'",g' $var_file
git_diff $var_file

# Ubuntu 20.04
distro=ubuntu
ver=20.04
action "Checking $distro $ver"
var_file="$VARS_DIR/$distro-$ver.pkrvars.hcl"
base_url="http://mirror.aarnet.edu.au/pub/ubuntu/releases/$ver"
output=$(curl -s -L "$base_url/SHA256SUMS" | grep -E 'live-server')
IFS=" " read -ra details <<< "$output"
filename="${details[1]#\*}"  # Strip * from start of filename
iso_url="$base_url/$filename"
iso_checksum="sha256:${details[0]}"
debug "url: $iso_url"
debug "checksum: $iso_checksum"
sed -i 's,\(iso_url\s\+=\).*$,\1 "'$iso_url'",g' $var_file
sed -i 's,\(iso_checksum\s\+=\).*$,\1 "'$iso_checksum'",g' $var_file
git_diff $var_file

# Ubuntu 22.04
distro=ubuntu
ver=22.04
action "Checking $distro $ver"
var_file="$VARS_DIR/$distro-$ver.pkrvars.hcl"
base_url="http://mirror.aarnet.edu.au/pub/ubuntu/releases/$ver"
output=$(curl -s -L "$base_url/SHA256SUMS" | grep -E 'live-server')
IFS=" " read -ra details <<< "$output"
filename="${details[1]#\*}"  # Strip * from start of filename
iso_url="$base_url/$filename"
iso_checksum="sha256:${details[0]}"
debug "url: $iso_url"
debug "checksum: $iso_checksum"
sed -i 's,\(iso_url\s\+=\).*$,\1 "'$iso_url'",g' $var_file
sed -i 's,\(iso_checksum\s\+=\).*$,\1 "'$iso_checksum'",g' $var_file
git_diff $var_file

# Ubuntu 24.04
distro=ubuntu
ver=24.04
action "Checking $distro $ver"
var_file="$VARS_DIR/$distro-$ver.pkrvars.hcl"
base_url="http://mirror.aarnet.edu.au/pub/ubuntu/releases/$ver"
output=$(curl -s -L "$base_url/SHA256SUMS" | grep -E 'live-server')
IFS=" " read -ra details <<< "$output"
filename="${details[1]#\*}"  # Strip * from start of filename
iso_url="$base_url/$filename"
iso_checksum="sha256:${details[0]}"
debug "url: $iso_url"
debug "checksum: $iso_checksum"
sed -i 's,\(iso_url\s\+=\).*$,\1 "'$iso_url'",g' $var_file
sed -i 's,\(iso_checksum\s\+=\).*$,\1 "'$iso_checksum'",g' $var_file
git_diff $var_file
