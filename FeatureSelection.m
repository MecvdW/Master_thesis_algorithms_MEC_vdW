function [ImportantFeatures,MainScores] = FeatureSelection(Out,Response,version,fig)
%In this function, two options for feature selection are given. One is the
%fscmrmr algorithm (a filter type feature selection method), the other is
%fitcensemble (an embedded type feature selection method)

% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071

if version == 1
    %Feature selection method is fscmrmr
    [idx,scores] = fscmrmr(Out,Response);
    % Choose features with an importance of more than 75% (arbitarily
    % chosen)
    % First find the max score
    MaxScore = max(scores);
    % Divide every score by the max score to get a relative result
    scores = scores./MaxScore;
    % Choose only the important features using the 25th percentile
    Pth = 25;
    Perc = prctile(scores,Pth);
    MainScores = (scores >= Perc);
    ImportantFeatures = Out(:,MainScores);
    if fig == 1
        figure; bar(scores)
        title('Importance of feature for classification'); xlabel('Features');ylabel('Importance')
    end
elseif version == 2
    % Feature selection method is fitcensemble
    Ens = fitcensemble(Out,Response,'Method','Bag', 'NumLearningCycles',500);
    % Calculate the feature importance
    imp = predictorImportance(Ens);
    % Choose features with an importance of more than 75% (arbitrarily
    % chosen)
    % First find the max score
    MaxImp = max(imp);
    % Divide every score by the max score to get a relative result
    imp = imp/MaxImp;
% Choose only the important features using the 25th percentile
    Pth = 25;
    Perc = prctile(imp,Pth);
    MainScores = (imp >= Perc);
    ImportantFeatures = Out(:,MainScores);
    if fig == 1
        figure; bar(imp)
        title('Importance of feature for classification'); xlabel('Features');ylabel('Importance')
    end
end
end
