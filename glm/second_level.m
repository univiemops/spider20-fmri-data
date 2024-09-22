% This scripts performs SECOND LEVEL GLM ANALYSIS with SPM12 for the SpiDA-MRI data paper 

% ---------------------------------------------------------------------------------------------------------------------------------
% #### analysis information ####

% path to main folder (here: one folder above fmriprep's "derivatives")
path = '/Volumes/ExtrmSSD_4T/Spider2021_deface';

% the results of the analysis will be put in e.g.,'/Volumes/ExtrmSSD_4T/Spider2021_deface/scidata_validation_analysis';
analysis_name = 'scidata_validation_analysis';

% list of participant ID e.g. {'sub-01', 'sub-02', 'sub-03', 'sub-04'}
participants = getSubID(fullfile(path, 'derivatives', 'fmriprep')); 

% compute second level analysis for stimulus positive (activation above implicit baseline) 
compute_second_level(path, participants, analysis_name, 'stimulus_positive - All Sessions')

% compute second level analysis for stimulus positive (activation below implicit baseline) 
compute_second_level(path, participants, analysis_name, 'stimulus_negative - All Sessions')


% ---------------------------------------------------------------------------------------------------------------------------------
% #### functions ####

function compute_second_level(path, participants, analysis_name, contrast_name)
    
    counter = 1; 

    for s = 1:length(participants)

        % 'sub-01'
        sub = participants{s}; 

        % first level results folder 
        fl_dir = fullfile(path, analysis_name, 'first_level', sub);

        % load SPM mat 
        load(fullfile(fl_dir, 'SPM.mat')); 

        % find contrast name
        index = find(strcmp({SPM.xCon.name}, contrast_name)); 
        contrastFileName = ['con_' num2str(index, '%04d') '.nii'];

        % find contrast files
        conFiles{counter}= fullfile(fl_dir, contrastFileName);
        counter = counter +1; 

    end
    
    matlabbatch{1}.spm.stats.factorial_design.dir = {fullfile(path, analysis_name, 'second_level', contrast_name)}; % folder for second level results 
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = conFiles'; % enter contrast files
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = contrast_name;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = 1;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    
    spm_jobman('run',matlabbatch);
    clear matlabbatch

end


