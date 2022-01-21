#!/bin/bash -e
# performs MNI template normalization

FSL_DIR=/usr/local/fsl


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

IMG_IN=${SUBJECT}_${SESSION}_T1w_deoblq_RPI_denoised

# warp resolution (default=10)
WR=10


echo Running MNI template normalization of ${IMG_IN}_brain_restore.nii.gz
	
flirt -ref ${FSL_DIR}/data/standard/MNI152_T1_0.8mm_brain -searchcost corratio -cost corratio -interp trilinear -dof 12 -bins 512 -in ${DERIV_DIR}/${IMG_IN}_brain_restore.nii.gz -omat ${DERIV_DIR}/${IMG_IN}_brain_restore_MNI-flirt.mat -out ${DERIV_DIR}/${IMG_IN}_brain_restore_MNI-flirt.nii.gz -searchrx -30 30 -searchry -30 30 -searchrz -30 30
	
		
echo Running nonlinear coregistration of ${IMG_IN}_brain_restore.nii.gz to MNI space
		
fnirt --in=${DERIV_DIR}/${IMG_IN}.nii --aff=${DERIV_DIR}/${IMG_IN}_brain_restore_MNI-flirt.mat --cout=${DERIV_DIR}/${IMG_IN}_MNI-fnirt --config=T1_2_MNI152_2mm -v --warpres=$WR,$WR,$WR
		
applywarp --ref=${FSL_DIR}/data/standard/MNI152_T1_0.8mm_brain --in=${DERIV_DIR}/${IMG_IN}_brain_restore.nii.gz --warp=${DERIV_DIR}/${IMG_IN}_MNI-fnirt.nii.gz --out=${DERIV_DIR}/${IMG_IN}_brain_restore_MNI.nii.gz --interp=spline
		
rm -f ${DERIV_DIR}/${IMG_IN}_brain_restore_MNI-flirt.nii.gz
		
rm -f ${DERIV_DIR}/*log
		
cp ${FSL_DIR}/data/standard/MNI152_T1_0.8mm_brain.nii.gz ${DERIV_DIR}/
		
echo Running nonlinear coregistration of ${IMG_IN}_brain_restore.nii.gz segmentations to MNI space
		
applywarp --ref=${FSL_DIR}/data/standard/MNI152_T1_0.8mm_brain --in=${DERIV_DIR}/${IMG_IN}_brain_restore-GM.nii.gz --warp=${DERIV_DIR}/${IMG_IN}_MNI-fnirt.nii.gz --out=${DERIV_DIR}/${IMG_IN}_brain_restore-GM_MNI.nii.gz --interp=nn
		
applywarp --ref=${FSL_DIR}/data/standard/MNI152_T1_0.8mm_brain --in=${DERIV_DIR}/${IMG_IN}_brain_restore-WM.nii.gz --warp=${DERIV_DIR}/${IMG_IN}_MNI-fnirt.nii.gz --out=${DERIV_DIR}/${IMG_IN}_brain_restore-WM_MNI.nii.gz --interp=nn

