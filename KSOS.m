% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

function KurSkew = KSOS(data,absmean,std,order)
% The kurtosis of the signal can be calculated by subtracting the mean from
% the specific value, powering the result to 4, summing all, and dividing
% by the fourth power of the standard deviation of length -1
for i = 1:size(data,2)
    dataSub(:,i) = data(:,i) - mean(absmean);
    dataOrder(:,i) = dataSub(:,i).^order;
    dataSum(i) = sum(dataOrder(:,i));
    KurSkew(i) = dataSum(i)/((size(data,2)-1)*(std(i)^order));
end
end
