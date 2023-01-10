% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

function [TransTotal, TransPos] = SStrans(data)
% With this function, the total amount of transitions between sleep stages
% over the entire night can be calculated
TransTotal = [];
TransPos = [];
for i = 1:length(data) -1
    if data(i) ~= data(i+1)
        TransPos(i) = 1;
    else
        TransPos(i) = 0;
    end
end
TransTotal = sum(TransPos);
end