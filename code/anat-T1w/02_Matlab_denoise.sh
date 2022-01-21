#!/bin/bash

# Runs Matlab removal of Rician distributed noise using an optimized NLM filter (ONLM), a beta value of 1.0, a patch radius of 1 voxel, and a search radius of 3 voxels


# Make sure to export environment variables before running this script!

# export PROJECT_DIR=/data/qb/Atlanta/projects/<project>
# (e.g. export PROJECT_DIR=/data/qb/Atlanta/projects/Woodbury-CDA2)

# export PIPELINE=<pipeName>
# (e.g. export PIPELINE=anat-T1w)

# export SUBJECT=sub-<subID>
# (e.g. export SUBJECT=sub-CES01)

# export SESSION=ses-<sesID>
# (e.g. export SESSION=ses-bl)


DERIV_DIR=${PROJECT_DIR}/derivatives/${PIPELINE}/${SUBJECT}/${SESSION}/anat

IMG_IN=${SUBJECT}_${SESSION}_T1w_deoblq_RPI


# matlab script must be run from MRI_DenoisingPkg_r01_pcode-cmdLn directory

MATLAB_DIR=${PROJECT_DIR}/code/${PIPELINE}/MRI_DenoisingPkg_r01_pcode-cmdLn
cd ${MATLAB_DIR}

echo Running denoising of ${IMG_IN}.nii

matlab -nosplash -nodisplay -r "MainMRIDenoising ${DERIV_DIR}/${IMG_IN}.nii;exit;"

