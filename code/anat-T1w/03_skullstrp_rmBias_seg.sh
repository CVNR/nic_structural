#!/bin/bash
# performs a skull strip, removes bias field, then segments tissues
# uses optiBET.sh for skull stripping (Script by Evan Lutkenhoff, lutkenhoff@ucla.edu
# Monti Lab (http://montilab.psych.ucla.edu) 


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


echo Running skull strip of ${IMG_IN}.nii.gz

# run optiBET.sh 
/bin/bash ${PROJECT_DIR}/code/${PIPELINE}/optiBET.sh -i ${DERIV_DIR}/${IMG_IN}.nii.gz -o #run optiBET.sh with 0.5mm MNI T1 mask


echo Running bias field removal of ${IMG_IN}_brain.nii.gz

fast -B ${DERIV_DIR}/${IMG_IN}_brain.nii.gz

# removes unnecessary interstitial images
rm -fv ${DERIV_DIR}/*pve*
rm -fv ${DERIV_DIR}/*flirt.mat
rm -fv ${DERIV_DIR}/*mixeltype*


echo Running tissue segmentation of ${IMG_IN}_brain.nii.gz

3dcalc -prefix ${DERIV_DIR}/${IMG_IN}_brain_restore-GM.nii.gz -a ${DERIV_DIR}/${IMG_IN}_brain_seg.nii.gz -expr 'equals(a,2)'

3dcalc -prefix ${DERIV_DIR}/${IMG_IN}_brain_restore-WM.nii.gz -a ${DERIV_DIR}/${IMG_IN}_brain_seg.nii.gz -expr 'equals(a,3)'

3dcalc -prefix ${DERIV_DIR}/${IMG_IN}_brain_restore-CSF.nii.gz -a ${DERIV_DIR}/${IMG_IN}_brain_seg.nii.gz -expr 'equals(a,1)'

