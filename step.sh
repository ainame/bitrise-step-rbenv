#!/bin/bash
set -ex

if [ -f .ruby-version ]; then
    ruby_version_file=$(cat .ruby-version)
fi
version="${ruby_version:-${ruby_version_file}}"
rbenv install --skip-existing "${version}"

installed_dir="$(rbenv root)/versions/${version}"

# The way adding break lines looks odd here but this is the way we need to follow...
if [ "${BITRISE_CACHE_INCLUDE_PATHS}" == "" ]; then
    cache_dir="
${installed_dir}"
else
    # BITRISE_CACHE_INCLUDE_PATHS typically includes a break line at the end
    cache_dir="${BITRISE_CACHE_INCLUDE_PATHS}
${installed_dir}"
fi

envman add --key BITRISE_CACHE_INCLUDE_PATHS --value "${cache_dir}"
