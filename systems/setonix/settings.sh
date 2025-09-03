#!/bin/bash
if [ -z ${__PSC_SETTINGS__+x} ]; then # include guard
__PSC_SETTINGS__=1

# EDIT at each rebuild of the software stack
DATE_TAG="2025.02"

if [ -z ${INSTALL_PREFIX+x} ]; then
    INSTALL_PREFIX="/software/setonix/${DATE_TAG}"
fi

if [ "${INSTALL_PREFIX%$DATE_TAG}" = "${INSTALL_PREFIX}" ]; then
    echo "The path in 'INSTALL_PREFIX' must end with ${DATE_TAG} but its value is ${INSTALL_PREFIX}"
    exit 1
fi

if [ -n "${PAWSEY_CLUSTER}" ] && [ -z ${SYSTEM+x} ]; then
    SYSTEM="$PAWSEY_CLUSTER"
fi

if [ -z ${SYSTEM+x} ]; then
    echo "The 'SYSTEM' variable is not set. Please specify the system you want to
    build Spack for."
    exit 1
fi

if [ "$USER" = "spack" ]; then
    INSTALL_GROUP="spack"
fi

if [ -z ${INSTALL_GROUP+x} ]; then
    echo "The 'INSTALL_GROUP' variable must be set to linux group that will own the installed files."
    exit 1
fi

# Note the use of '' instead of "" to allow env variables to be present in config files
USER_PERMANENT_FILES_PREFIX='/software/projects'
USER_TEMP_FILES_PREFIX='/scratch'
SPACK_USER_CONFIG_PATH="$MYSOFTWARE/setonix/$DATE_TAG/.spack_user_config"
BOOTSTRAP_PATH='$MYSOFTWARE/setonix/'$DATE_TAG/.spack_user_config/bootstrap
# Set a new mirror where to fetch prebuilt binaries, if any.
SPACK_BUILDCACHE_PATH=${INSTALL_PREFIX}/build_cache
# When SPACK_POPULATE_CACHE=1, spack will push binaries in the above cache location for later use.
# The operation will be executed after having installed the environments.
# Useful when building the stack on the test system.
SPACK_POPULATE_CACHE=0

pawseyenv_version="${DATE_TAG}"

# Reframe files - moved to Reframe test scripts
RFM_SETTINGS_FILE=${PAWSEY_SPACK_CONFIG_REPO}/systems/${SYSTEM}/rfm_files/rfm_settings.py
RFM_STORAGE_DIR=${INSTALL_PREFIX}/rfm_results
RFM_TEST_FILE=${PAWSEY_SPACK_CONFIG_REPO}/systems/${SYSTEM}/rfm_files/rfm_checks.py

archs="zen3"
# compiler versions (needed for module trees with compiler dependency)
gcc_version="14.2.0"
gcc_versionO="13.3.1"
cce_version="18.0.0"
aocc_version="5.0.0"

# architecture of login/compute nodes (needed by Singularity symlink module)
cpu_arch="zen3"

# tool versions
spack_version="0.23.1" # the prefix "v" is added in setup_spack.sh
singularity_version="4.1.0-nompi" # has to match the version in the Spack env yaml + nompi tag
singularity_mpi_version="4.1.0-mpi" # has to match the version in the Spack env yaml + mpi tag
shpc_version="0.1.30"
shpc_registry_version="6daa16631460b9a93db2b9580dae360397d00aa7"

# python (and py tools) versions
python_name="python"
python_version="3.11.6" # has to match the version in the Spack env yaml
setuptools_version="59.4.0" # has to match the version in the Spack env yaml
pip_version="23.1.2" # has to match the version in the Spack env yaml
# r major minor version
r_version_majorminor="4.4.1"
# reframe major minor version
reframe_version="3.12.0"

# list of module categories
module_cat_list="
astro-applications
bio-applications
applications
libraries
programming-languages
utilities
visualisation
python-packages
benchmarking
developer-tools
dependencies
"

# list of spack build environments - missing vis
env_list="
vis
"
### TYPICALLY NO EDIT NEEDED PAST THIS POIINT

# python version info (no editing needed)
python_version_major="$( echo $python_version | cut -d '.' -f 1 )"
python_version_minor="$( echo $python_version | cut -d '.' -f 2 )"
python_version_bugfix="$( echo $python_version | cut -d '.' -f 3 )"

# shpc module directories for all users (system-wide and user-specific)
shpc_allusers_modules_dir_long="modules-long"
shpc_allusers_modules_dir_short="views/modules"
# shpc module suffix for SPACK USER (system-wide)
shpc_spackuser_container_tag="-container"
# name of SHPC module: decide this once and for all
shpc_name="shpc"

# name of Singularity module (Spack has singularity and singularityce)
singularity_name="singularity"
singularity_name_general="singularityce"

# NOTE: the following are ALL RELATIVE to root_dir above
# root location for Pawsey custom builds
custom_root_dir="custom"
# root location for Pawsey utilities (spack, shpc, scripts)
utilities_root_dir="pawsey"
# root location for containers
containers_root_dir="containers"
# location for Pawsey custom build modules
custom_modules_dir="${custom_root_dir}/modules"
# location for Pawsey custom build software
custom_software_dir="${custom_root_dir}/software"
# location for Pawsey utility modules
utilities_modules_dir="${utilities_root_dir}/modules"
# location for Pawsey utility software
utilities_software_dir="${utilities_root_dir}/software"
# location for SHPC container modules
shpc_containers_modules_dir="${containers_root_dir}/${shpc_allusers_modules_dir_short}"
# location for SHPC container modules (long version, as installed)
shpc_containers_modules_dir_long="${containers_root_dir}/${shpc_allusers_modules_dir_long}"
# location for SHPC containers
shpc_containers_dir="${containers_root_dir}/sifs"

# suffix for Pawsey custom build modules
custom_modules_suffix="custom"
# suffix for Project modules
project_modules_suffix=""   # "project-apps" # let us keep it standard vs spack
# suffix for User modules
user_modules_suffix=""   # "user-apps" # let us keep it standard vs spack

# location of SHPC utility installation
shpc_install_dir="${utilities_software_dir}/${shpc_name}"
# location of SHPC utility modulefile
shpc_module_dir="${utilities_modules_dir}/${shpc_name}"

# location of Singularity modulefile (arch/compiler free symlink)
singularity_symlink_module_dir="${utilities_modules_dir}/${singularity_name}"

# location for Spack modulefile
spack_module_dir="${utilities_modules_dir}/spack"

# Use the Cray provided ROCm until we have a stable custom build.

ROCM_VERSIONS=(
"6.1.3"
)

ROCM_PATHS=(
"/opt/rocm-6.1.3"
)

fi # end include guard
