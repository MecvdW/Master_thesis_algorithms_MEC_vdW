% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

function Ratio = RSEAE(data,power)
% The ratio of signal energy to the power of all epochs can be calculated
% by dividing the signal energy per epoch by the average power of all
% epochs
powerAve = mean(power);
Ratio = data/powerAve;
end