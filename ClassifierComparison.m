% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

function b = ClassifierComparison(Out, Response)
% First make the classifier
b = fitcknn(Out,Response,'NumNeighbors',10,'Distance','spearman');
end