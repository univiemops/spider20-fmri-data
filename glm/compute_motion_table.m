
% main path to data 
path = '/Volumes/ExtrmSSD_4T/Spider2021_deface'; 

% get list of participant ids 
participants = getSubID(fullfile(path, 'derivatives', 'fmriprep'), {'sub-01', 'sub-02', 'sub-04'}); 

% for each confounds timeseries file of each run, check if max(fd) > 5
for s = 1:length(participants)

    sub = participants{s}; % 'sub-01'
    
    funcPath = fullfile(path, 'derivatives', 'fmriprep', sub, 'func');

    for run = 1:5
 
        cdFile = fullfile(funcPath, [sub '_task-passiveview_run-' num2str(run) '_desc-confounds_timeseries.tsv']);
        rp = readtable(cdFile, 'Delimiter', '\t', 'FileType', 'text');
        fd = rp.framewise_displacement; 

        if nanmean(fd) > 0.5 || max(fd) > 5 
            excluded(s, run) = true; 
        else
            excluded(s, run) = false; 
        end
        
    end

end

% put in table
motion_table = table(participants', excluded); 
motion_table.Properties.VariableNames =  ["subID";"excluded_runs"]; 

% save which run is excluded as logical array (nsub x nruns) 
save('excluded_runs.mat', 'motion_table','-mat')

