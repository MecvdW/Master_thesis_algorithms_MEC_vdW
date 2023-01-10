% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

function FormF = FFOS(data)
% The form factor of the signal can be calculated by dividing the RMS of
% the signal by the squared absolute mean of the signal
% First calculate the squared of the mean of the signal
absquad = data.^2;
abssqrt = sqrt(absquad);
abssqrt2 = sqrt(abssqrt);
absmean = sum(abssqrt2)/length(data);
% Now calculate the form factor
FormF = rms(data)/absmean;
end