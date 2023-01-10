% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

function std = ASTDF(dataLeft, dataRight, Mean)
% To find the absolute standard deviation of the signal, first the
% difference between the EOG signals from Left and Right has to be found by
% subtraction. After, the standard deviation can be calculated by
% subtracting the mean value from the specific value, squaring the outcome,
% summing all of those values together, and dividing this by the number of
% samples -1
diff = dataLeft - dataRight;
for i = 1:size(diff,1)
    diffSub(i,:) = diff(i,:) - Mean;
end
diffSquare = diffSub.^2;
diffSum = sum(diffSquare);
std = diffSum./(length(diff)-1);
end