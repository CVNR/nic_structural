#!/bin/bash -e

# Reads in raw T1w image, deobliques it, and axializes it into the RPI orientation


# Make sure to export environment variables before running this script!

# export PROJECT_DIR=/data/qb/Atlanta/projects/<project>
# (e.g. export PROJECT_DIR=/data/qb/Atlanta/projects/Woodbury-CDA2)

# export PIPELINE=<pipeName>
# (e.g. export PIPELINE=anat-T1w)

# export SUBJECT=sub-<subID>
# (e.g. export SUBJECT=sub-CES01)

# export SESSION=ses-<sesID>
# (e.g. export SESSION=ses-bl)


RAW_DIR=${PROJECT_DIR}/${SUBJECT}/${SESSION}/anat

DERIV_DIR=${PROJECT_DIR}/derivatives/${PIPELINE}/${SUBJECT}/${SESSION}/anat

IMG_IN=${SUBJECT}_${SESSION}_T1w


mkdir -p ${DERIV_DIR}

echo "Running deoblique of ${IMG_IN}.nii.gz"

3dWarp -verb -deoblique -quintic -prefix ${DERIV_DIR}/${IMG_IN}_deoblq.nii.gz ${RAW_DIR}/${IMG_IN}.nii.gz


echo "Running RPI orientation of ${IMG_IN}_deoblq.nii.gz"
		
3daxialize -verb -axial -orient RPI -prefix ${DERIV_DIR}/${IMG_IN}_deoblq_RPI.nii.gz ${DERIV_DIR}/${IMG_IN}_deoblq.nii.gz

		
gunzip ${DERIV_DIR}/${IMG_IN}_deoblq_RPI.nii.gz

# removes unnecessary insterstitial image		
rm -f ${DERIV_DIR}/${IMG_IN}_deoblq.nii.gz

