% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

function TotalEnergy = EPS(data,datalength)
%Power of a signal can be found by calculating the square of the signal at
%every time step and than summing all together and dividing by the length
%of the time step. The chosen windows for the calculation of the square is
%1s, the chosen window for the calculation of the power is 30s.
TotalEnergy = (sum(data.^2))/(length(datalength));
end