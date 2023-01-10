% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

function RFWs = ROW(energy1,energy2)
% With this function, the ratio between two adjacent epochs can be
% calculated
RFWs = energy2/energy1;
end