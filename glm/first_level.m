% This scripts performs FIRST LEVEL GLM ANALYSIS with SPM12 for the SpiDA-MRI data paper 

% ---------------------------------------------------------------------------------------------------------------------------------
% #### analysis information ####

% path to main folder (here: one folder above fmriprep's "derivatives")
path = '/Volumes/ExtrmSSD_4T/Spider2021_deface';

% the results of the analysis will be put in e.g.,'/Volumes/ExtrmSSD_4T/Spider2021_deface/scidata_validation_analysis';
analysis_name = 'scidata_validation_analysis';

% list of participant ID e.g. {'sub-01', 'sub-02', 'sub-03', 'sub-04'}
participants = getSubID(fullfile(path, 'derivatives', 'fmriprep')); 

% load motion_table that contains which run is excluded or not 
load(fullfile(path, analysis_name, 'excluded_runs.mat')); 


% ---------------------------------------------------------------------------------------------------------------------------------
% #### Run SPM batch. For each participant, we: 

% 1. create a design matrix 
% 2. estimate GLM parameters
% 3. define first level contrast 

parfor n = 1:length(participants)

    % e.g. 'sub-01'
    sub = participants{n}; 
    
    % returns the list of valid (i.e., non excluded) runs e.g. [1 2 4 5]
    valid_runs = find(~(motion_table.excluded_runs(contains(motion_table.subID, sub), :))); 

    % 1. create a design matrix 
    create_SPM_design_matrix(path, sub, analysis_name, valid_runs); 
    fprintf(['SPM design matrix of ' sub ' has been created. \n']);

    % 2. estimate GLM parameters
    estimate_from_SPM_design_matrix(path, sub, analysis_name); 
    fprintf(['GLM parameters of ' sub ' have been estimated. \n']);

    % 3. define first level contrast 
    define_first_level_contrasts(path, sub, analysis_name); 
    fprintf(['Contrasts of ' sub ' have been calculated. \n']);

end

% ---------------------------------------------------------------------------------------------------------------------------------
% #### functions ####

function create_SPM_design_matrix(path, sub, analysis_name, valid_runs)

    % path to functional scans
    funcPath = fullfile(path, 'derivatives', 'fmriprep', sub, 'func');
    
    % create folder to store first level results if it does not exist
    fl_dir = fullfile(path, analysis_name, 'first_level', sub);
    if ~exist(fl_dir, 'dir')
        mkdir(fl_dir)
    end

    % specify fMRI acquisition parameters
    matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr(fl_dir); 
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1.25;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 56;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 28;

    counter = 1; % to re-index matlabbatch in case some runs are missing

    for run = valid_runs

        % select scans
        scans = cellstr(spm_select('ExtFPList',funcPath, ['^s6_' sub '_task-passiveview_run-' num2str(run) '_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'], 1:345));

        % get onset file
        onsetDirs = dir(fullfile(path, analysis_name, 'onsets', sub, ['/*run_' num2str(run) '_spider20.csv']));
        onsetFile = [onsetDirs(end).folder filesep onsetDirs(end).name];
            
        % get onsets for spiders
        [onsets_sp, ~] = getOnsets(onsetFile, 'spider');

        % get onsets for neutral pictures 
        [onsets_ne, ~] = getOnsets(onsetFile, 'neutral');
       
        % get onsets for button-press catch trials 
        [onsets_cat, dt] = getOnsets(onsetFile, 'catch');

        % combine spider and neutral pictures to create a single "stimulus" regressor
        onsets = sort([onsets_sp; onsets_ne]);

        % get confound file for motion parameters
        cdFiles   = fullfile(funcPath, [sub '_task-passiveview_run-' num2str(run) '_desc-confounds_timeseries.tsv']);

        % specify design : one reg for stimulus; one for button-press catch trials
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).scans = scans;
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).cond(1).name      = 'STIMULUS';
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).cond(1).onset     = onsets;
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).cond(1).duration  = 4;
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).cond(1).tmod      = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).cond(1).pmod      = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).cond(1).orth      = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).cond(2).name      = 'CATCH';
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).cond(2).onset     = onsets_cat;
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).cond(2).duration  = dt;
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).cond(2).tmod      = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).cond(2).pmod      = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).cond(2).orth      = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).multi             = {''};

        % add realignment values as regressors of no interest
        rp = tdfread(cdFiles); 
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).regress(1).name   = 'trans_x';
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).regress(1).val    = rp.trans_x';
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).regress(2).name   = 'trans_y';
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).regress(2).val    = rp.trans_y';
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).regress(3).name   = 'trans_z';
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).regress(3).val    = rp.trans_z';
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).regress(4).name   = 'rot_x';
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).regress(4).val    = rp.rot_x';
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).regress(5).name   = 'rot_y';
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).regress(5).val    = rp.rot_y';
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).regress(6).name   = 'rot_z';
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).regress(6).val    = rp.rot_z';

        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).multi_reg = {''};        
        matlabbatch{1}.spm.stats.fmri_spec.sess(counter).hpf = 128;

        counter = counter + 1; 

    end

    matlabbatch{1}.spm.stats.fmri_spec.delete = 1;
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

    spm_jobman('run',matlabbatch); 
    clear matlabbatch
            
end

function estimate_from_SPM_design_matrix(path, sub, analysis_name)

    fl_dir = fullfile(path, analysis_name, 'first_level', sub);
    matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{1}.spm.stats.fmri_est.spmmat = {fullfile(fl_dir,'SPM.mat')};

    spm_jobman('run',matlabbatch);
    clear matlabbatch

end

function define_first_level_contrasts(path, sub, analysis_name)

    fl_dir = fullfile(path, analysis_name, 'first_level', sub);
    
    % Contrast 1: Positive Activation compared to implicit baseline (above baseline) 
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'stimulus_positive';
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.convec = [1 0];
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'replsc';
    
    % Contrast 2: Negative Activation compared to implicit baseline (below baseline) 
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'stimulus_negative';
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.convec = [-1 0];
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'replsc';

    matlabbatch{1}.spm.stats.con.delete = 1;
    matlabbatch{1}.spm.stats.con.spmmat = {fullfile(fl_dir,'SPM.mat')};

    spm_jobman('run',matlabbatch);
    clear matlabbatch

end


