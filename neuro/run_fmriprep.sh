#!/bin/bash

# Inputs
bidsdir=/Volumes/ExtrmSSD_2T/Spider2021/Nifti
outputdir=/Volumes/ExtrmSSD_2T/Spider2021/derivatives
workdir=/Volumes/ExtrmSSD_2T/Spider2021/derivatives/scratch
fslicdir=/Volumes/ExtrmSSD_2T/Spider2021/license.txt

subj=52
nthreads=7
ompnthreads=14
mem=12000

# Run fmriprep
fmriprep-docker $bidsdir $outputdir \
participant \
 --participant-label $subj \
  -w $workdir \
 --fs-license-file $fslicdir \
 --fs-no-reconall \
 --output-spaces MNI152NLin2009cAsym MNI152NLin6Asym T1w \
 --use-aroma \
 --stop-on-first-crash \
 --nthreads $nthreads \
 --omp-nthreads $ompnthreads \
 --mem-mb $mem



