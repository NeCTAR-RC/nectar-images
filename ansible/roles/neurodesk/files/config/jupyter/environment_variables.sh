#!/bin/bash

# Neurodesktop environment variables, adapted for the Nectar VDS image from
# upstream's config/jupyter/environment_variables.sh (see UPSTREAM_REF).
# Upstream's container/HPC-only logic (Slurm mode selection, Ollama host,
# Apptainer/macOS runtime detection, AI agent paths) is omitted.
#
# Sourced from /etc/profile.d/neurodesktop.sh (interactive shells) and from
# /opt/neurodesktop/kernel_wrapper.sh (every Jupyter kernel spawn), so it
# must stay safe to source non-interactively: exports always run,
# informational messages are guarded below.

if [ -z "$NEURODESKTOP_ENV_SOURCED" ]; then
    export NEURODESKTOP_ENV_SOURCED=1

    if [[ -z "${NB_USER}" ]]; then
        export NB_USER=${USER}
    fi
    if [[ -z "${USER}" ]]; then
        export USER=${NB_USER}
    fi
fi

# MODULEPATH and CVMFS detection run on every source so that new shells and
# kernels pick up CVMFS if it was not mounted when the session started.
export OFFLINE_MODULES=/neurodesktop-storage/containers/modules/
export CVMFS_MODULES=/cvmfs/neurodesk.ardc.edu.au/neurodesk-modules/

# MODULEPATH is built to match the transparent-singularity module layout:
# each subdirectory of CVMFS_MODULES becomes its own MODULEPATH entry so
# Lmod presents modules as <tool>/<version> rather than
# <category>/<tool>/<version>.
if [ -d "$CVMFS_MODULES" ]; then
        cvmfs_expanded=`echo ${CVMFS_MODULES}* | sed 's/ /:/g'`
        if [ -d "$OFFLINE_MODULES" ]; then
                # Local container installations take priority over CVMFS
                export MODULEPATH=${OFFLINE_MODULES}:${cvmfs_expanded}
        else
                export MODULEPATH=${cvmfs_expanded}
        fi
        export CVMFS_DISABLE=false
        unset cvmfs_expanded
else
        # CVMFS genuinely unavailable
        export MODULEPATH=${OFFLINE_MODULES}
        export CVMFS_DISABLE=true
fi

# Show informational messages in interactive terminals only, once per session
if [ -z "$NEURODESKTOP_MSG_SHOWN" ] && [ -f '/usr/share/module.sh' ]; then
        if [[ $- == *i* ]]; then
                export NEURODESKTOP_MSG_SHOWN=1
                if [ -d "${OFFLINE_MODULES}" ] && [ -d "${CVMFS_MODULES}" ]; then
                        echo "Found local container installations in $OFFLINE_MODULES. Using installed containers with a higher priority over CVMFS."
                fi

                echo 'Neuroimaging tools are accessible via the Neurodesktop Applications menu and running them through the menu will provide help and setup instructions. If you are familiar with the tools and you want to combine multiple tools in one script, you can run "ml av" to see which tools are available and then use "ml <tool>/<version>" to load them. '

                if [[ "$CVMFS_DISABLE" == "true" ]]; then
                        echo "CVMFS not available. Using local containers stored in ${OFFLINE_MODULES}"
                        if [ ! -d "${OFFLINE_MODULES}" ]; then
                                echo 'Neurodesk tools not yet downloaded. Choose tools to install from the Neurodesktop Application menu.'
                        fi
                fi
        fi
fi

export APPTAINER_BINDPATH=/data,/mnt,/neurodesktop-storage,/tmp,/cvmfs
export APPTAINERENV_SUBJECTS_DIR=${HOME}/freesurfer-subjects-dir
export MPLCONFIGDIR=${HOME}/.config/matplotlib-mpldir

# Nextflow ecosystem (upstream sets these as Dockerfile ENV)
export NF_NEURO_MODULES_DIR=/opt/nf-neuro/modules
export NF_TEST_HOME=/opt/nf-test

case ":${PATH}:" in
        *":${HOME}/.local/bin:"*) ;;
        *) PATH="${PATH}:${HOME}/.local/bin" ;;
esac
case ":${PATH}:" in
        *":/opt/conda/bin:"*) ;;
        *) PATH="${PATH}:/opt/conda/bin:/opt/conda/condabin" ;;
esac
export PATH

# Plain Linux VM: no writable-overlay workaround needed (upstream only sets
# one for macOS Docker and rootless Apptainer runtimes)
export neurodesk_singularity_opts=""
