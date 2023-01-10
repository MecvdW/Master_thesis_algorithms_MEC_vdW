% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

function Std = STDOF(data,absmean)
% The standard deviation of the signal can be calculated by subtracting the
% mean value from the specific value, squaring the outcome, summing all of those values together,
% and dividing this by the number of samples -1
for i = 1:size(data,2)
    dataSub(:,i) = data(:,i) - mean(absmean);
    dataSquare(:,i) = dataSub(:,i).^2;
    dataSum(i) = sum(dataSquare(:,i));
    Stdfrac(i) = dataSum(i)/(size(data,2)-1);
    Std(i) = sqrt(Stdfrac(i));
end
end