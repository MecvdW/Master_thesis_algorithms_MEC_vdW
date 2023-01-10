% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

function Ratio = RSS(data,dataAll)
% The ratio of signal form factor to the form factor of all signals can be calculated
% by dividing the signal form factor per epoch by the average form factor of all
% signals
Ave1 = mean2(dataAll);
Ave2 = mean2(data);
Ave = (Ave1 + Ave2)/2;
Ratio = data/Ave;
end