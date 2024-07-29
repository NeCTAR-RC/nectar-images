#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

[[ -n ${DEBUG:-} ]] && set -o xtrace
ERROR=0

## Colours
all_off="$(tput sgr0)"
bold="${all_off}$(tput bold)"
black="${bold}$(tput setaf 0)"
red="${bold}$(tput setaf 1)"
green="${bold}$(tput setaf 2)"
yellow="${bold}$(tput setaf 3)"
blue="${bold}$(tput setaf 4)"

# Message helpers
msg() {
    printf "%s\n" "$1"
}
debug() {
    [ $DEBUG ] && printf "%s:: %s%s\n" "${black}" "$1" "${all_off}"
}
success() {
    printf "%s\u2714%s %s%s\n" "${green}" "${bold}" "$1" "${all_off}"
}
info() {
    printf "%s::%s %s%s\n" "${blue}" "${bold}" "$1" "${all_off}"
}
action() {
    printf "%s==>%s %s%s\n" "${green}" "${bold}" "$1" "${all_off}"
}
error() {
    printf "%s\u274c%s %s%s\n" "${red}" "${bold}" "$1" "${all_off}"
    ERROR=$((ERROR+1))
}


### Ansible
# NOTE: We require Ansible 2.16. Python 3.6 (used in EL8 is dropped in 2.17)
_ansible_version="2.16"

if hash ansible >/dev/null 2>&1; then
    ansible_version=$(ansible --version | head -n1 | grep -Eo '[0-9]\.[0-9]+')
    if [[ "${_ansible_version}" != "${ansible_version}" ]]; then
        error "Nectar images builder requires Ansible ${_ansible_version}. Found ${ansible_version}."
    else
        success "Ansible ${ansible_version} found."
    fi
else
    error "Nectar images builder requires Ansible ${_ansible_version}. No Ansible found in path."
fi


### Packer
# At least this version
_packer_version="1.9.5"

if hash packer >/dev/null 2>&1; then
    packer_version="$(packer version | head -n1 | cut -d 'v' -f 2 || true)"
    stty sane   # ^ command messes up the console output for some reason
    if [[ "${_packer_version}" != $(echo -e "${_packer_version}\n${packer_version}" | sort -s -t. -k 1,1 -k 2,2n -k 3,3n | head -n1) ]]; then
        error "Nectar images builder requires Packer ${_packer_version}. Found ${packer_version}."
    else
        success "Packer ${packer_version} found."
    fi
else
    error "Nectar images builder requires Packer ${_packer_version}. No packer found in path."
fi


### Everything else

for tool in openstack nc; do
    if hash $tool >/dev/null 2>&1; then
        success "$tool found."
    else
        fatal "$tool found."
    fi
done

exit $ERROR
