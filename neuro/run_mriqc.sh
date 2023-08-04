#!/bin/bash

# Inputs:
topdir=/Volumes/ExtrmSSD_2T/Spider2021
bidsdir=/Volumes/ExtrmSSD_2T/Spider2021/Nifti
subj=52
nthreads=2
mem=10

# Make mriqc directory and participant directory in derivatives folder
if [ ! -d $topdir/derivatives/mriqc ]; then
mkdir $topdir/derivatives/mriqc
fi

if [ ! -d $topdir/derivatives/mriqc/sub-${subj} ]; then
mkdir $topdir/derivatives/mriqc/sub-${subj}
fi

# Run MRIQC
docker run -it --rm -v $bidsdir:/data:ro -v $topdir/derivatives/mriqc/sub-${subj}:/out \
  nipreps/mriqc:21.0.0rc2 /data /out \
  participant \
  --participant-label $subj\
  --n_proc $nthreads \
  --correct-slice-timing \
  --mem_gb $mem \
  --float32 \
  --ants-nthreads $nthreads \
  -w $topdir/derivatives/mriqc/sub-${subj}
