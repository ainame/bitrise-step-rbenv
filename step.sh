#!/bin/bash
set -ex

function setup_rbenv {
    platform="$(uname -s)"
    case "${platform}" in
        Darwin*) # macOS
            brew update
            brew outdated ruby-build || brew upgrade ruby-build
            ;;
        Linux*)
            # https://github.com/rbenv/rbenv-installer
            curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
            PATH=~/.rbenv/bin:$PATH
            eval "$(rbenv init -)"
            # Store rbenv init settings for other steps
            ~/.rbenv/bin/rbenv init 2> ~/.bashrc
            ;;
        *)
            echo "ERROR: Unknown platform found ${platform}"
            ;;
    esac
    curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-doctor | bash
}

setup_rbenv

# Read .ruby-version
if [ -f .ruby-version ]; then
    ruby_version_file=$(cat .ruby-version)
fi

# Determine Ruby version to be installed
version="${ruby_version:-${ruby_version_file}}"

# Install Ruby if not installed yet
rbenv install --skip-existing "${version}"

installed_dir="$(rbenv root)/versions/${version}"

# The way adding break lines looks odd here but this is the way we need to follow...
if [ "${BITRISE_CACHE_INCLUDE_PATHS}" == "" ]; then
    cache_dir="
${installed_dir}"
else
    cache_dir="${BITRISE_CACHE_INCLUDE_PATHS}
${installed_dir}"
fi

envman add --key BITRISE_CACHE_INCLUDE_PATHS --value "${cache_dir}"
