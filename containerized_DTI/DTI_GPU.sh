#!/bin/bash
chmod a+x DTA_GPU.sh

FSLDIR=/usr/local/fsl
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH
. ${FSLDIR}/etc/fslconf/fsl.sh


##----------------------
## General setup...
##----------------------

# data directory
wdir=/media/barbeylab/extradrive2/INSIGHT1b/DTI
temp=/media/barbeylab/extradrive2/INSIGHT1b/temp


# sub list
sublist=$( ls ${wdir} | egrep 'sub-[[:digit:]]{4}' )
#subject=$( echo $1 ) #`cat subs_to_process_c.txt`

for subject in ${sublist}
do

if test -d ${wdir}/${subject}; then
echo "  DTI analysis looks done--double check DTI/${subject} or delete to re-run."

elif test ! -e ${temp}/Running.${subject}; then
touch ${temp}/Running.${subject}

cd ${wdir}/${subject}/

for session in ses-*
do
bedpostx_gpu ${wdir}/${subject}/${session}/.
done

rm ${temp}/Running.${subject}
fi

done
