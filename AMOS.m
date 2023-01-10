% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

function absmean = AMOS(data)
% To find the absolute mean of a signal, the signal should first be made
% absolute, after which the absolute mean can be calculated
absquad = data.^2;
abs = sqrt(absquad);
absmean = sum(abs)/length(data);
end