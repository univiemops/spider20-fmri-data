# "SpiDa" - an arachnophobia dataset including fMRI and behavioural data 

This repository contains scripts for behavioral data from 49 participants performing behavioral avoidance tasks (BAT) and a passive viewing task of spider images in the fMRI scanner. These scripts are associated with the manuscript (). If you use the dataset or associated code, please cite the following paper: 


## Cloning the Repository and Downloading the Data 
 
To clone this repository run:  
`$ git clone https://github.com/univiemops/spider20-fmri-data.git` 

The dataset is available on OpenNeuro: (URL)

## Experiment presentations
[exp/spider20_v4.py](https://github.com/univiemops/spider20-fmri-data/blob/main/exp/spider20_v4.py) contains a PsychoPy script to present spider images during the fMRI scan. \
[exp/spider_slider_new.psyexp]() contains PsychoPy script for the virtual BAT experiment. 

## Preprocessing and quality control
[neuro/dcm2bids.sh](https://github.com/univiemops/spider20-fmri-data/blob/main/neuro/dcm2bids.sh) is the shell script to convert dicom images to nifit images and then sort them into the BIDS format. \
[neuro/run_fmriprep.sh](https://github.com/univiemops/spider20-fmri-data/blob/main/neuro/run_fmriprep.sh) is the shell script to perform the preprocessing. The dataset was preprocessed using fMRIprep (version 20.2.6 ) in a Docker container. \
[neuro/run_mriqc.sh](https://github.com/univiemops/spider20-fmri-data/blob/main/neuro/run_mriqc.sh) is used to assess the quality of the fMRI data. It runs through the defalut mriqc (version 1.4.0) pipeline to compute image quality metrics. \
[neuro/image_quality_plot.R](https://github.com/univiemops/spider20-fmri-data/blob/main/neuro/image_quality_plot.R) is the script that generated the quality control figures we plotted in the paper. It replotted the results from mriqc to show the temporal SNR of each run across all participants and framewise displacement of each run across all participants.



