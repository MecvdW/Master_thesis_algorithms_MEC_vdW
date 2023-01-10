% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

function Energy = REE(data)
% The relative energy in the 0-2Hz frequency band can be calculated by
% first computing the energy of the signal itself and the average energy of all
% epochs separately. Afterwards, the relative energy can be calculated by
% dividing the energy of the signal itself through the average energy of
% all epochs. The energy of a signal in the frequency domain can be calculated by taking the
% Fourier transform of the signal.
ESAll = mean(data,2);
for k = 1:size(data,2)
    Energy(:,k) = data(:,k)./ESAll;
end
end



