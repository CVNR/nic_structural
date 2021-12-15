# NIC Structural Pre-Processing Guide


## De-oblique and re-orientation

```Bash
cd /data/qb/Atlanta/projects/<projectID>/code/<pipeline>/
./01_deobliq-RPI.sh
```

To check the output of this script, use the AFNI tool `3dinfo` to check the orientation of the dataset, filling in `project`, `pipeline`, `subID`, and `sesID` appropriate to your project:

```Bash
cd /data/qb/Atlanta/projects/<projectID>/derivatives/<pipeline>/sub-<subID>/ses-<sesID>/anat/
3dinfo sub-<subID>_ses-<sesID>_T1w_deoblq_RPI.nii
```

In the `Data Axes Orientation:` field, there should be a `-orient RPI` label.

### What this script does:

Sometimes a dataset is acquired at an oblique angle (off the Anterior-Posterior axis) in order to cover the whole brain and to reduce MRI-induced artifacts caused by air and water in the eyes and nose.  The de-oblique step uses the AFNI `3dWarp` tool with the `-deobliqe` option to perform a spatial transformation of the dataset to a cardinal (Anterior-Posterior axis aligned) dataset.  Also, dataset axes can be oriented in various directions based on acquisition settings or after certain processing steps.  Orientation axes are Left-Right, Anterior-Posterior, and Superior-Inferior.  The de-oblique step outputs the dataset in the RAI orientation where the x-axis increases from Right-to-Left, the y-axis increases from Anterior-to-Posterior, and the z-axis increases from Inferior-to-Superior.  `3daxialize` with the -orient RPI option sets this orientation to RPI instead.  For more information see the References below.


### References:

[3dWarp](https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3dWarp_sphx.html#ahelp-3dwarp)

[3daxialize](https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/3daxialize_sphx.html#ahelp-3daxialize)


## Rician noise removal

```Bash
cd /data/qb/Atlanta/projects/<projectID>/code/<pipeline>/
./02_denoise.sh
```

The output image should appear less “grainy” as variances in intensity due to noise have been removed.  Otherwise, there should be no structural changes made to the image.

### What this script does:

This tool removes noise through the implementation of an Optimized Non Local-means (ONLM) filter.  For more information see the References below.

### References:

P. Coupe, J. V. Manjon, E. Gedamu, D. Arnold, M. Robles, D. L. Collins Robust Rician Noise Estimation for MR Images. Medical Image Analysis, 14(4) : 483-493, 2010

P. Coupé, P. Yger, S. Prima, P. Hellier, C. Kervrann, C. Barillot. An Optimized Blockwise NonLocal Means Denoising Filter for 3-D Magnetic Resonance Images. IEEE Transactions on Medical Imaging, 27(4):425–441, 2008.

N. Wiest-Daessle, S. Prima, P. Coupe, S.P. Morrissey, C. Barillot.  Rician noise removal by non-local means filtering for low signal-to-noise ratio MRI: Applications to DT-MRI. In 11th International Conference on Medical Image Computing and Computer-Assisted Intervention, MICCAI'2008, Pages 171-179, New York, Etats-Unis, September 2008


## Non-brain tissue removal, field inhomogeneity correction, and tissue segmentation

```Bash
cd /data/qb/Atlanta/projects/<projectID>/code/<pipeline>/
./03_skullstrp_rmBias_seg.sh
```

To check the output of this script, overlay the output brain mask onto the input image.  Reduce the opacity of the brain mask overlay to better view brain/non-brain interfaces.  Move through multiple slices of the image looking for regions where the mask is cutting off brain tissue as this is undesired.  Regions where the mask was too inclusive (allowing regions of non-brain tissue within the mask) is not as critical of an issue unless the study is focused on segmentation of brain tissues.  Optimally, the output image should have most non-brain tissue removed and not have any brain tissue missing.  The intensity should also be more consistent between tissues of the same type in the output image when compared to the input.  To check the segmentation masks, overlay the output segmentation mask `…-GM.nii.gz`, `…-WM.nii.gz` onto the magnetic-field corrected image `…_restore.nii.gz`.  Reduce the opacity of the segmentation mask overlay to better view brain tissue type interfaces, and move through multiple slices of the image looking for regions where the mask is not including significant regions of appropriate brain tissue type (GM, WM) as this is undesired.

### What this script does:

This script removes non-brain tissue via the `optiBET` tool, an optimized brain extraction tool in FSL that adds a MNI registration step to improve removal of non-brain tissue.  `optiBET` creates a subset list of voxels, called a brain mask, that we wish to analyze.  In this brain mask, voxels within the brain are assigned a value of “1” while the rest of the voxels are assigned a value of “0”.  This mask is then applied to the input image so that the output image voxel intensity values within the brain are unchanged and the output image voxel intensities outside the brain become zero.  Also, the magnetic field within the scanner should be constant but is in reality attenuated as it passes through the different tissues which make up the brain (gray matter (GM), white matter (WM), and cerebrospinal fluid (CSF)).  The `fast` tool from FSL corrects these inhomogeneities so that brain tissue-type boundaries are less difficult to determine.  Differing intensities across these voxel boundaries are then labeled as either `GM`, `WM`, or `CSF` using a hidden Markov random field method along with an Expectation-Maximization algorithm.  For more information see the References below.

### References:

Lutkenhoff ES, Rosenberg M, Chiang J, Zhang K, Pickard JD, Owen AM, Monti MM. (2014) Optimized Brain Extraction for Pathological Brains (optiBET). PLoS ONE 9(12): e115551. doi:10.1371/journal.pone.0115551

Zhang, Y. and Brady, M. and Smith, S. Segmentation of brain MR images through a hidden Markov random field model and the expectation-maximization algorithm. IEEE Trans Med Imag, 20(1):45-57, 2001.


## Spatial normalization to MNI template

```Bash
cd /data/qb/Atlanta/projects/<projectID>/code/<pipeline>/
./04_spatnorm.sh
```

To check the output of this script, open the MNI template and the output brain image.  The axial and saggital views are most helpful.  Check to see if anatomical structures are located in the same positions (ventricles, corpus callosum etc…).  This comparison can be done by either overlaying the images in `fsleyes` and adjusting the opacity to view the images back and forth or using multiple sessions in AFNI and selecting structures with the crosshairs.

## What this script does:

This script normalizes the input image brain to a standardized template so that meaningful comparisons can be made across subjects with differing brain shapes and sizes.  The FSL tool `flirt` runs an initial affine registration followed by the `fnirt` tool which runs a non-linear localized registration of the input anatomical image to a standard MNI template `MNI152_T1_0.8mm`, then applies the final registration matrix via `applywarp` to align the input image brain structures to those of the standard template.

References:

[flirt](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FLIRT)

[fnirt](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FNIRT)
