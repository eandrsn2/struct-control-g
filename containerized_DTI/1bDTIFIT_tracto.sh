#!/bin/bash
chmod a+x 1bDTIFIT_arbitrary_tracto_sub.sh

FSLDIR=/usr/local/fsl
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH
. ${FSLDIR}/etc/fslconf/fsl.sh
export PATH=/usr/lib/cuda-9.1/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/lib/cuda-9.1/lib64

FREESURFER_HOME=/usr/local/freesurfer
export FREESURFER_HOME
source $FREESURFER_HOME/SetUpFreeSurfer.sh
SUBJECTS_DIR=/media/barbeylab/Elements/CNLM/FMRIPREP/freesurfer
export SUBJECTS_DIR



subdir=/media/barbeylab/extradrive2/INSIGHT1b/DTI
hcp=/media/barbeylab/extradrive2/INSIGHT1b/XCP
func=/media/barbeylab/extradrive2/INSIGHT1b/FMRIPREP/fmriprep
fmriprep=//media/barbeylab/extradrive2/INSIGHT1b/FMRIPREP
surfer=/media/barbeylab/extradrive2/INSIGHT1b/FMRIPREP/freesurfer
sdir=/media/barbeylab/extradrive1/scripts/CNLM
temp=/media/barbeylab/extradrive1/temp
tempDTI=/media/barbeylab/extradrive1/Insight/DTI

IMAGEDIR=/media/barbeylab/extradrive1/images

sublist=$( ls ${subdir} | egrep 'sub-' )

export parcellation_number=82

export parcellation_labels_file=ROInames.txt


for subject in ${sublist}
do

if [ ! -f '/media/barbeylab/extradrive1/temp/running_'${subject}  ]; then

touch '/media/barbeylab/extradrive1/temp/running_'${subject}

cd ${subdir}/${subject}/

for session in ses-?
do
        time=$session
        cd ${subdir}/${subject}/${time}.bedpostX
        echo "Running Probtrackx2"
        
        sed -i -e 's#masks/#masksDKsub2/#g' ${subdir}/${subject}/${time}.hcpmmp.trax/masksDKsub2/masks.txt 
        
        rm ${subdir}/${subject}/${time}.hcpmmp.trax/conn82_*
        rm ${subdir}/${subject}/${time}.hcpmmp.trax/conn_82.csv

        
        probtrackx2_gpu --network -x ${subdir}/${subject}/${time}.hcpmmp.trax/masksDKsub2/masks.txt \
            -l \
            -c 0.2 \
            -S 2000 \
            --steplength=0.5 \
            -P 5000 \
            --fibthresh=0.01 \
            --distthresh=0.0 \
            --avoid=${subdir}/${subject}/${time}.hcpmmp.trax/ventricles.fa.nii.gz \
            --sampvox=0.0 \
            --forcedir \
            --opd \
            -s merged \
            -m nodif_brain_mask \
            --dir=${subdir}/${subject}/${time}.hcpmmp.trax 
           # --onewaycondition \
           # --waypoints=${subdir}/${subject}/${time}.hcpmmp.trax/waypoints.txt \
           # --waycond='OR'


        if [ -f ${subdir}/${subject}/${time}.hcpmmp.trax/fdt_network_matrix ] && [ ! -f ${subdir}/${subject}/${time}.hcpmmp.trax/conn82_VolumeWeighted.csv ]; then
        cd ${subdir}/${subject}/${time}.hcpmmp.trax
        export RESDIR=${subdir}/${subject}/${time}.hcpmmp.trax
        export labeldir=${subdir}/${subject}/${time}.hcpmmp.trax
        
        rm ROIVol.txt
        rm ROInames.txt
        for ROI in $(seq 1 ${parcellation_number}); do
            number=$(awk -v "I=$ROI" 'NR==I {print $1}' /media/barbeylab/extradrive1/scripts/DesikanNodeNamesSub2.txt)
            name=$(awk -v "I=$ROI" 'NR==I {print $2}' /media/barbeylab/extradrive1/scripts/DesikanNodeNamesSub2.txt)
            name=$( echo $name | sed 's/lh.//g; s/rh.//g; s/.label//g' )
            echo "${name}," $(fslstats ${subdir}/${subject}/${time}.hcpmmp.trax/masksDKsub2/${number}_${name}.nii.gz -V) >> ROIVol.txt
            echo "${number} ${name}" >> ROInames.txt
        done
        rm ROI_Volumes.csv
        awk '{print $1, $2}' ROIVol.txt > ROIVol2.txt
        sed 's/^ *//g' ROIVol2.txt >  ROI_Volumes.csv
        rm ROIVol.txt ROIVol2.txt
        
        
        #convert naming of raw connectome file
        python ${sdir}/FSL_convert_fdtmatrix_csv.py
        #compute transformation on Connectivity matrix
        python ${sdir}/volume_weight_connectome.py
        #add column headers for connectome file which is required for visualization
        python ${sdir}/add_column_headers.py
            
            
        echo "Processing completed for ${subject}"
        echo "........................................"
        rm ${temp}/Running.${subject}.hcpmmp.trax
        fi

done
fi
done
