% this function simply returns a list of participants as they are named in the
% 'datapath' folder 

function participants = getSubID(datapath, participants_to_exclude)

    allDir = dir([datapath, '/sub*']);
    subDir = allDir([allDir.isdir]); 
    participants = {subDir.name}; 
	participants  = participants(~contains(participants, participants_to_exclude)'); 

end