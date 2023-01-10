% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

function Energy = EnergyAll(data)
% The energy of a signal in the frequency domain can be determined by
% calculating the Fourier transform of the signal
Energy = fft(data,[],1);
end