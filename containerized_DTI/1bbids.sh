#!/bin/bash
IMAGEDIR=/media/barbeylab/extradrive1/images

cd /media/barbeylab/extradrive2/INSIGHT1b/DICOM/pre_testing

for i in ./*Insight*_4*
do
CLEANSUBJECT="${i##*/}"
CLEANSUBJECT=$(echo $CLEANSUBJECT | egrep -o '4[[:digit:]]{3}_[[:digit:]]{1}' | head -n1)
CLEANSESSION=${CLEANSUBJECT#*_}
CLEANSUBJECT=${CLEANSUBJECT%_*}  
echo $CLEANSESSION
echo $CLEANSUBJECT

#singularity exec --bind /media/barbeylab:/media/barbeylab, $IMAGEDIR/heudiconv.simg heudiconv -f /media/barbeylab/extradrive1/scripts/1b/1bheudiconv.py --overwrite --files $i/ -o /media/barbeylab/extradrive2/INSIGHT1b/1bBIDS -s $CLEANSUBJECT -ss $CLEANSESSION -b

#hardcore broken bids shit converter
rm -rf $i/temp
for z in $i/*
do
echo $i
echo $z

mkdir $i/temp
cd $i
cp -r ./$(basename $z) ./temp/$(basename $z)
cd ..
rm -rf /media/barbeylab/extradrive2/INSIGHT1b/1bBIDS/.heudiconv/${CLEANSUBJECT}/ses-${CLEANSESSION}
singularity exec --bind /media/barbeylab:/media/barbeylab, $IMAGEDIR/heudiconv.simg heudiconv -f /media/barbeylab/extradrive1/scripts/1b/1bheudiconv.py --overwrite --files $i/temp/$(basename $z) -o /media/barbeylab/extradrive2/INSIGHT1b/1bBIDS -s $CLEANSUBJECT -ss $CLEANSESSION -b

rm -rf $i/temp/$(basename $z)

done

rm -rf $i/temp

DTI=ses-${CLEANSESSION}/dwi/sub-${CLEANSUBJECT}_ses-${CLEANSESSION}_dwi.nii.gz

sed -i "1 s|{|{\n\"IntendedFor\": \"${DTI}\",|" /media/barbeylab/extradrive2/INSIGHT1b/1bBIDS/sub-$CLEANSUBJECT/ses-$CLEANSESSION/fmap/sub-${CLEANSUBJECT}_ses-${CLEANSESSION}_run-2_phasediff.json
sed -i "1 s|{|{\n\"IntendedFor\": \"${DTI}\",|" /media/barbeylab/extradrive2/INSIGHT1b/1bBIDS/sub-$CLEANSUBJECT/ses-$CLEANSESSION/fmap/sub-${CLEANSUBJECT}_ses-${CLEANSESSION}_run-2_magnitude1.json
sed -i "1 s|{|{\n\"IntendedFor\": \"${DTI}\",|" /media/barbeylab/extradrive2/INSIGHT1b/1bBIDS/sub-$CLEANSUBJECT/ses-$CLEANSESSION/fmap/sub-${CLEANSUBJECT}_ses-${CLEANSESSION}_run-2_magnitude2.json

done
