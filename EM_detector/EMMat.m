% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

function EMArray = EMMat(Events,EMArray)
% The periods of all eye movement events in the results from the automatic
% EM detector and the gold standards are found using this function
for o = 1:size(Events,1)
    period = (Events(o,1):Events(o,2))';
    EMArray(period) = 1;
end
end