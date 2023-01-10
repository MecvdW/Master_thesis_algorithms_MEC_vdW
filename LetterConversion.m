% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

function [FeaturesOut, ResponseOut] = LetterConversion(Features,Response)
% W = 1, REM = 0, N1 = -1, N2 = -2, N3 = -3
for i = 1:size(Features,1)
    if Features{i,2} == 'W'
        Features{i,2} = 1;
    elseif Features{i,2} == 'REM'
        Features{i,2} = 0;
    elseif Features{i,2} == 'N1'
        Features{i,2} = -1;
    elseif Features{i,2} == 'N2'
        Features{i,2} = -2;
    elseif Features{i,2} == 'N3'
        Features{i,2} = -3;    
    end
end
% HS = 1, RBD = 2, RBD-PD = 3, RBD+PD = 4
for i = 1:size(Features,1)
    if Features{i,1} == 'HS'
        Features{i,1} = 1;
        Response(1,i) = 1;
    elseif Features{i,1} == 'RBD'
        Features{i,1} = 2;
        Response(1,i) = 2;
    elseif Features{i,1} == 'PD-RBD'
        Features{i,1} = 3;
        Response(1,i) = 3;
    elseif Features{i,1} == 'PD+RBD'
        Features{i,1} = 4;
        Response(1,i) = 4;
    end
end
% Make double instead of table
Features = table2array(Features);
FeaturesOut = double(Features);
ResponseOut = double(Response);
end