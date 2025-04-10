#!/bin/bash -e

if [ -n "${PAWSEY_CLUSTER}" ] && [ -z ${SYSTEM+x} ]; then
    SYSTEM="$PAWSEY_CLUSTER"
fi

if [ -z ${SYSTEM+x} ]; then
    echo "The 'SYSTEM' variable is not set. Please specify the system you want to
    build Spack for."
    exit 1
fi

PAWSEY_SPACK_CONFIG_REPO=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )
. "${PAWSEY_SPACK_CONFIG_REPO}/systems/${SYSTEM}/settings.sh"

# for first run, use cray-python, because there is no Spack python yet
module load cray-python
# initialise spack 
. "${INSTALL_PREFIX}/spack/share/spack/setup-env.sh"

# Initialise GPG keys to sign build cache
# This needs to be run on login nodes seems like.
if [ ${SPACK_POPULATE_CACHE} -eq 1 ]; then
    spack gpg init
    spack gpg create Spack spack@pawsey.org.au

    # Create/add mirror
    spack mirror add systemwide_buildcache "${SPACK_BUILDCACHE_PATH}"
fi

# make sure Clingo is bootstrapped
echo "Running 'spack spec nano' to bootstrap Clingo.."
spack spec nano

# first thing we need is Python
# spec gcc
echo "Concretization of Python.."
spack spec python@${python_version} %gcc@${gcc_version}
#spack spec python@${python_version} %cce@${cce_version}

echo "Installing Python with default compilers.."
for arch in $archs; do
    sg $INSTALL_GROUP -c "spack install -j128 --no-checksum python@${python_version} %gcc@${gcc_version} target=$arch"
#    sg $INSTALL_GROUP -c "spack install -j128 --no-checksum python@${python_version} %cce@${cce_version} target=$arch"
done
