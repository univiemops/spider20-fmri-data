function [onsets, dt] = getOnsets(onsetFile, condition)
    tbl = readtable(onsetFile, 'PreserveVariableNames', true);
%     tbl = readtable(onsetFile, 'VariableNamingRule', 'preserve'); 
    switch condition
        case 'spider' 
            i = contains(tbl.('picture ID'), 'Sp_'); 
            onsets = tbl.('onset')(i); dt = []; 
        case 'neutral'
            i = contains(tbl.('picture ID'), 'Ne_'); 
            onsets = tbl.('onset')(i); dt = []; 
        case 'catch'
            i = contains(tbl.('picture ID'), 'catch'); 
            onsets = tbl.('onset')(i); 
            dt = tbl.('reaction time')(i); 
        case 'fixation'
            i = or(contains(tbl.('picture ID'), 'Sp_'), contains(tbl.('picture ID'), 'Ne_')); 
            onsets = tbl.onset(i) - tbl.jitter(i); 
            dt = tbl.jitter(i);
            onsets(1) = []; % remove the first one to be safe
            dt(1) = []; 
    end
    onsets = onsets(~isnan(onsets));
end