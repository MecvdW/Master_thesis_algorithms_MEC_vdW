% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078
function [Es,f,indxs] = Energy(data,freqs,fs)
% With this function, the energy content in the frequency domain of a
% specific frequence band can be calculated
N = (length(data)+1)/2;
f = (fs/2)/N*(0:N-1);
indxs = find(f>freqs(1) & f<freqs(2));
Es = goertzel(data,indxs);
end