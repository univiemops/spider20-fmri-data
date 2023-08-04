#!/bin/bash

set -e

# Define pathways
topdir=/Volumes/ExtrmSSD_2T/Spider2021
dcmdir=/Volumes/ExtrmSSD_2T/Spider2021/Dicom
dcm2niidir=/Volumes/ExtrmSSD_2T/Spider2021/dcm2niix_3-Nov-2020_mac
onsetdir=/Volumes/ExtrmSSD_2T/Spider2021/Onsets
mkdir -p ${topdir}/Nifti
niidir=${topdir}/Nifti

# Create dateset description json file
rm -f ${niidir}/dataset_description.json # remove the description file if it exists

jo -p "Name"="Spider2021 Imaging Data" "BIDSVersion"="1.6.0" >> ${niidir}/dataset_description.json

# Create anat, func and fmap folders
#for subj in "$dcmdir/"*; do
for subj in sub-52; do
	thissubj=${subj##*/}
	echo "Processing subject $thissubj"

mkdir -p ${niidir}/${thissubj}/anat
mkdir -p ${niidir}/${thissubj}/func
mkdir -p ${niidir}/${thissubj}/fmap

for direcs in func; do
${dcm2niidir}/dcm2niix -o ${niidir}/${thissubj} -f ${thissubj}_%f_%p -i y ${dcmdir}/${thissubj}/
done

cd ${niidir}/${thissubj}

# Remove localization scan
rm *AAHead*

# Organize anat folder
anatfiles=$(ls -1 *t1* | wc -l)
for ((i=1;i<=${anatfiles};i++)); do
Anat=$(ls *t1*)   
tempanat=$(ls -1 $Anat | sed '1q;d') # Capture new file to change
tempanatext="${tempanat##*.}"
tempanatfile="${tempanat%.*}"
mv ${tempanatfile}.${tempanatext} ${niidir}/${thissubj}/anat/${thissubj}_T1w.${tempanatext} # Rename file and move it to anat folder
echo "${tempanat} changed to ${thissubj}_T1w.${tempanatext}"
done

# Organize func folder
## passive viewing
funcfiles=$(ls -1 *epi_r* | wc -l)
for ((i=1;i<=${funcfiles};i++)); do
Func=$(ls *epi_r*)   
tempfunc=$(ls -1 $Func | sed '1q;d') 
tempfuncext="${tempfunc##*.}"
tempfuncfile="${tempfunc%.*}"
run=${tempfuncfile: -1}
mv ${tempfuncfile}.${tempfuncext} ${niidir}/${thissubj}/func/${thissubj}_task-passiveview_run-${run}_bold.${tempfuncext} # Rename file and move it to func folder
echo "${tempfunc} changed to ${thissubj}_task-passiveview_run-${run}_bold.${tempafuncext}"
done

## resting state
restfiles=$(ls -1 *rest* | wc -l)
for ((i=1;i<=${restfiles};i++)); do
Rest=$(ls *rest*)
temprest=$(ls -1 $Rest | sed '1q;d')
temprestext="${temprest##*.}"
temprestfile="${temprest%.*}"
temppart=$(echo $temprestfile |cut -d '_' -f5)
mv ${temprestfile}.${temprest##*.} ${niidir}/${thissubj}/func/${thissubj}_task-rest${temppart}_bold.${temprestext}
echo "${temprest} changed to ${thissubj}_task-rest${temppart}_bold.${temprestext}"
done

# Organize fmap folder
## phase difference files
phasefiles=$(ls -1 *e2_ph* | wc -l)
for ((i=1;i<=${phasefiles};i++)); do
Phase=$(ls *e2_ph*)
tempphase=$(ls -1 $Phase | sed '1q;d')
tempphaseext="${tempphase##*.}"
tempphasefile="${tempphase%.*}"
mv ${tempphasefile}.${tempphase##*.} ${niidir}/${thissubj}/fmap/${thissubj}_phasediff.${tempphaseext}
echo "${tempphase} changed to ${thissubj}_phasediff.${tempphaseext}"
done

## magnitude files
magfiles=$(ls -1 *field_mapping* | wc -l)
for ((i=1;i<=${magfiles};i++)); do
Mag=$(ls *field_mapping*)
tempmag=$(ls -1 $Mag | sed '1q;d')
tempmagext="${tempmag##*.}"
tempmagfile="${tempmag%.*}"
number=${tempmagfile: -1}
mv ${tempmagfile}.${tempmag##*.} ${niidir}/${thissubj}/fmap/${thissubj}_magnitude${number}.${tempmagext}
echo "${tempmag} changed to ${thissubj}_magnitude${number}.${tempmagext}"
done

## spcify field map intended for to phasediff json file
cd ${niidir}/${thissubj}
intendedfiles="$(ls func/*.nii)"

cd ${niidir}/${thissubj}/fmap
phdiffjson=$(ls *phasediff.json*)
jq '. |= . + {"IntendedFor":[]}' ${phdiffjson} > intendedadd.json
for item in $intendedfiles; do
jq --arg value "$item" '.IntendedFor |= . + [$value]' intendedadd.json > tmp.json && mv tmp.json intendedadd.json
done

rm ${phdiffjson}
mv intendedadd.json ${phdiffjson}

# Add task name to json file
cd ${niidir}/${thissubj}/func
for funcjson in $(ls *.json); do
jsonname="${funcjson%.*}"
taskfield=$(echo $jsonname | cut -d '_' -f2 | cut -d '-' -f2)
jq '. |= . + {"TaskName":"'${taskfield}'"}' ${funcjson} > tasknameadd.json
rm ${funcjson}
mv tasknameadd.json ${funcjson}
echo "TaskName was added to ${jsonname} and matches the tasklabel in the filename"
done

# Create event tsv files
cd ${onsetdir}/${thissubj}

i=1
for f in $(ls -1 *.csv); do
awk -F';' '{ if ($6==0) $6=4; if ($6==1 || $6==2 || $6==3) $6=0; print $0 }' OFS=';' "${f}" > temp.csv
awk -F';' '{print $4,$6,$1,$2,$3,$5,$8}' OFS='\t' temp.csv > temp2.csv
sed -e '1s/catch/duration/' temp2.csv > temp3.csv
cat temp3.csv | sed '2d;$d'| sed 's/,/\t/g' > ${niidir}/${thissubj}/func/${thissubj}_task-passiveview_run-${i}_events.tsv
i=$(( i + 1 ))
rm **temp**
done

done
