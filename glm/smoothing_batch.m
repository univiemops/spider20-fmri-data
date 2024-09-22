% This scripts smoothes functional scans with SPM12 

% ---------------------------------------------------------------------------------------------------------------------------------
% #### analysis information ####

% path to main folder (here: one folder above fmriprep's "derivatives")
path = '/Volumes/ExtrmSSD_4T/Spider2021_deface';

% list of participant ID e.g. {'sub-01', 'sub-02', 'sub-03', 'sub-04'}
participants = getSubID(fullfile(path, 'derivatives', 'fmriprep')); 


parfor n = 1:length(participants)

    % 'sub-01'
    sub = participants{n};

    % path to functional scans
    funcPath = fullfile(path, 'derivatives', 'fmriprep', sub, 'func');

    for run = 1:5
        
        % name of scans to smooth
        filename = [sub '_task-passiveview_run-' num2str(run) '_space-MNI152NLin2009cAsym_desc-preproc_bold.nii']; 

        % unzip if necessary
        if ~exist(filename, "file")
            
            gunzip([funcPath filesep filename '.gz'])
            fprintf(['\nThe file: ' filename '.gz\nfrom folder: ' funcPath '\nhas been unzipped\n'])

        end

        % select scans
        scans = cellstr(spm_select('ExtFPList',funcPath, ['^' filename], 1:345));

        % smoothing SPM batch 
        smoothing(scans)
        fprintf(['\nThe scan: ' filename '\nfrom folder: ' funcPath '\nhas been smoothed\n'])

    end

end

function smoothing(scans)
        
    matlabbatch{1}.spm.spatial.smooth.data = scans; 
    matlabbatch{1}.spm.spatial.smooth.fwhm = [6 6 6];
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = 's6_';

    spm_jobman('run',matlabbatch);
    clear matlabbatch

end

