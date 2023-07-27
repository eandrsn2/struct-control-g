#!/bin/bash
chmod a+x DTA_FA.sh

FSLDIR=/usr/local/fsl
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH
. ${FSLDIR}/etc/fslconf/fsl.sh

export PATH=/usr/lib/cuda-9.1/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/lib/cuda-9.1/lib64

FREESURFER_HOME=/usr/local/freesurfer
export FREESURFER_HOME
source $FREESURFER_HOME/SetUpFreeSurfer.sh
SUBJECTS_DIR=/media/barbeylab/extradrive2/INSIGHT1b/FMRIPREP/freesurfer
export SUBJECTS_DIR


IMAGEDIR=/media/barbeylab/extradrive1/images
EDDYFILE=/media/barbeylab/extradrive1/scripts/1b/eddy_params.json


##----------------------
## General setup...
##----------------------

# data directory
bids_dir=/media/barbeylab/extradrive2/INSIGHT1b/1bBIDS
wdir=/media/barbeylab/extradrive2/INSIGHT1b/DTI
temp=/media/barbeylab/extradrive2/INSIGHT1b/temp

# sub list
sublist=$( ls ${bids_dir} | egrep 'sub-[[:digit:]]{4}' )
#subject=$( echo $1 ) #`cat subs_to_process_c.txt`

for subject in ${sublist}
do

if test -d ${wdir}/${subject}; then
echo "  DTI analysis looks done--double check DTI/${subject} or delete to re-run."

elif test ! -e ${temp}/Running.${subject}; then
touch ${temp}/Running.${subject}
mkdir ${wdir}/${subject}
echo "  Setting up for DTI..."
mkdir ${temp}/${subject}
mkdir /media/barbeylab/extradrive2/INSIGHT1b/tempfm/${subject}
cp -r ${bids_dir}/${subject} ${temp}/${subject}
cp ${bids_dir}/dataset_description.json ${temp}/${subject}

nice -n 19 singularity exec --cleanenv --nv --bind /media/barbeylab/:/media/barbeylab/,$IMAGEDIR/license.txt:$IMAGEDIR/license.txt,${temp}/${subject}:/datain,/media/barbeylab/extradrive2/INSIGHT1b/DTI:/dataout,/media/barbeylab/extradrive2/INSIGHT1b/tempfm/${subject}:/work $IMAGEDIR/qsiprep.sif qsiprep --output-space T1w --output-resolution 1.8750 --fs-license-file $IMAGEDIR/license.txt --participant_label ${subject} --hmc_model eddy --eddy-config ${EDDYFILE} --nthreads 8 --omp-nthreads 8 -w /work /datain /dataout participant

cd ${wdir}/qsiprep/${subject}/

for session in ses-*
do
mkdir ${wdir}/${subject}/${session}/
cd ${wdir}/qsiprep/${subject}/${session}/dwi
dtifit -k ${subject}_${session}_space-T1w_desc-preproc_dwi.nii.gz -m ${subject}_${session}_space-T1w_desc-brain_mask.nii.gz -b ${subject}_${session}_space-T1w_desc-preproc_dwi.bval -r ${subject}_${session}_space-T1w_desc-preproc_dwi.bvec -o ${wdir}/${subject}/${session}/dtifit

cp ${subject}_${session}_space-T1w_desc-preproc_dwi.bval ${wdir}/${subject}/${session}/bvals
cp ${subject}_${session}_space-T1w_desc-preproc_dwi.bvec ${wdir}/${subject}/${session}/bvecs
cp ${subject}_${session}_space-T1w_desc-preproc_dwi.nii.gz ${wdir}/${subject}/${session}/data.nii.gz
cp ${subject}_${session}_space-T1w_desc-brain_mask.nii.gz ${wdir}/${subject}/${session}/nodif_brain_mask.nii.gz
cd  ${wdir}/qsiprep/${subject}/anat 
cp ${subject}*.nii.gz ${wdir}/${subject}/${session}
rm -rf ${wdir}/${subject}/${session}/*MNI152*nii.gz

#bedpostx_gpu ${wdir}/${subject}/${session}/.
done

rm -rf ${temp}/${subject}
rm ${temp}/Running.${subject}
rm -rf /media/barbeylab/extradrive2/INSIGHT1b/tempfm/${subject}
fi

done
