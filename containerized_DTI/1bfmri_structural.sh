#!/bin/bash
chmod a+x 1bfmri_structural.sh
IMAGEDIR=/media/barbeylab/extradrive1/images

cd /media/barbeylab/extradrive2/INSIGHT1b/1bBIDS

subList=$( ls '/media/barbeylab/extradrive2/INSIGHT1b/1bBIDS' )

for i in $subList
do
echo $i
CLEANSUBJECT=$(echo $i | egrep -o '[[:digit:]]{4}' | head -n1)
echo $CLEANSUBJECT


if [ ! -f /media/barbeylab/extradrive2/INSIGHT1b/temp/running_${CLEANSUBJECT} ] && [ ! -d /media/barbeylab/extradrive1/INSIGHT1b/FMRIPREP/freesurfer/sub-${CLEANSUBJECT} ]; then
#if [ ! -f /media/barbeylab/extradrive2/INSIGHT1b/temp/running_${CLEANSUBJECT} ]; then

touch /media/barbeylab/extradrive2/INSIGHT1b/temp/running_${CLEANSUBJECT} 

mkdir /media/barbeylab/extradrive2/INSIGHT1b/temp/${CLEANSUBJECT}
cp -r /media/barbeylab/extradrive2/INSIGHT1b/1bBIDS/sub-${CLEANSUBJECT} /media/barbeylab/extradrive2/INSIGHT1b/temp/${CLEANSUBJECT}/

rm -rf /media/barbeylab/extradrive2/INSIGHT1b/temp/${CLEANSUBJECT}/sub-${CLEANSUBJECT}/ses-2 /media/barbeylab/extradrive2/INSIGHT1b/temp/${CLEANSUBJECT}/sub-${CLEANSUBJECT}/ses-1/func /media/barbeylab/extradrive2/INSIGHT1b/temp/${CLEANSUBJECT}/sub-${CLEANSUBJECT}/ses-1/dwi /media/barbeylab/extradrive2/INSIGHT1b/temp/${CLEANSUBJECT}/sub-${CLEANSUBJECT}/ses-1/fmap

printf $(($(date +%s) + 30)) > /media/barbeylab/extradrive2/INSIGHT1b/clock 
until [[ $(cat /media/barbeylab/extradrive2/INSIGHT1b/clock)  < $(date +%s) ]] 
do
sleep 120
done
printf $(($(date +%s) + 300)) > /media/barbeylab/extradrive2/INSIGHT1b/clock 

nice -n 19 singularity exec --cleanenv --bind /media/barbeylab/:/media/barbeylab/,$IMAGEDIR/license.txt:/opt/freesurfer/license.txt,/media/barbeylab/extradrive2/INSIGHT1b/temp/${CLEANSUBJECT}:/datain,/media/barbeylab/extradrive1/INSIGHT1b/FMRIPREP:/dataout,/media/barbeylab/extradrive2/INSIGHT1b/:/work $IMAGEDIR/fmriprep.simg fmriprep --output-spaces fsnative --fs-license-file /opt/freesurfer/license.txt -v --participant_label ${CLEANSUBJECT} --anat-only -w /work/tempfm /datain/ /dataout/ participant --nthreads 8 --omp-nthreads 8

rm -rf /media/barbeylab/extradrive2/INSIGHT1b/temp/${CLEANSUBJECT}/
rm /media/barbeylab/extradrive2/INSIGHT1b/temp/running_${CLEANSUBJECT}
rm -rf /media/barbeylab/extradrive2/INSIGHT1b/tempfm/fmriprep_wf/single_subject_${CLEANSUBJECT}_wf
fi
done
