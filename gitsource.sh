#!/bin/bash
# pkgsource.sh - source pkgbuild and return the stuff we use
# arguments: <path>

source "${1}/PKGBUILD" > /dev/null 2>&1

# return "NULL" if this doesn't appear to be a package
if [[ ${pkgname} == '' ]]; then
    echo "NULL"
    exit 0
fi

# build provides from entire PKGBUILD to include pkg definitions, not just global declaration
provides_list=()
eval $(awk '/^[[:space:]]*provides=/,/\)/' "${1}/PKGBUILD" | \
    sed -e "s/provides=/provides_list+=/" -e "s/#.*//" -e 's/\\$//')

# build output reply to build server
string="${pkgname[*]}|${provides_list[*]}|${pkgver}|${pkgrel}|${depends[*]}|${makedepends[*]}"

# attach our buildarch and noautobuild declarations, if present
if [[ ${buildarch} ]]; then
    string="$string|${buildarch}"
else
    string="$string|1"
fi
if [[ ${noautobuild} ]]; then
    string="$string|${noautobuild}"
else
    string="$string|0"
fi
if [[ ${highmem} ]]; then
    string="$string|1"
else
    string="$string|0"
fi

# return
echo ${string}
