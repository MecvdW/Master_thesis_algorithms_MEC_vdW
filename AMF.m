% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

function Mean = AMF(dataLeft,dataRight)
% To find the absolute mean of the signal, first the difference between the
% EOG signals from Left and Right has to be found by substraction. After,
% the mean of the result per epoch can be calculated.
diff = dataLeft - dataRight;
Mean = mean(diff);
end