% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

function [b,MainScores] = Classifier(Out, MF, fig)
if isempty(MF)
    % Random forest calculation
    b = TreeBagger(50,Out,Out(:,1),'Method','classification','OOBPredictorImportance','On');
    % Determine most important features using b.OOBPermutedPredictorDeltaError
    maxFeat = max(b.OOBPermutedPredictorDeltaError);
    % Divide every score by the max score to get a relative result
    Features = b.OOBPermutedPredictorDeltaError/maxFeat;
    figure; bar(Features)
    title('Importance of feature for classification'); xlabel('Features');ylabel('Importance')
    % Choose most important features
    Pth = 25;
    Perc = prctile(Features,Pth);
    MainScores = (Features >= Perc);
    ImportantFeatures = Out(:,MainScores);
    % Rerun the Random Forest with the most important features
    b = TreeBagger(100,ImportantFeatures,Out(:,1),'Method','classification','OOBPredictorImportance','On');
else
    % Random forest calculation
    b = TreeBagger(100,MF,Out(:,1),'Method','classification','OOBPredictorImportance','On');
    MainScores = [];
end
% Inspect behavior of classifier
if fig == 1
    % Inspect ensemble error with growing more trees
    figure; plot(oobError(b)); xlabel('Number of Grown Trees'); ylabel('Out-of-Bag Classification Error')
    % Find the fraction of observations that are in bag for all trees
    finbag = zeros(1,b.NumTrees);
    for t=1:b.NTrees
        finbag(t) = sum(all(~b.OOBIndices(:,1:t),2));
    end
    finbag = finbag / size(Out,1);
    figure; plot(finbag); xlabel('Number of Grown Trees'); ylabel('Fraction of In-Bag Observations')
    % Find ROC curves of all classes
    [Yfit,Sfit] = oobPredict(b); figure;
    for i = 1:length(b.ClassNames)
        posnmbr = string(i);
        pos = find(strcmp(b.ClassNames,posnmbr));
        ROCObj = rocmetrics(b.Y,Sfit(:,pos),posnmbr);
        plot(ROCObj); hold on
        %Save ROC metrics
        ROCObjAll{i} = ROCObj;
    end
    figure;
    for i = 1:length(b.ClassNames)
        % Open ROC metrics again
        ROCObj = ROCObjAll{i};
        % Find accuracy of ensemble for every class
        ROCObj = addMetrics(ROCObj,'Accuracy');
        plot(ROCObj.Metrics.Threshold,ROCObj.Metrics.Accuracy);xlabel('Threshold for ''good'' Returns');ylabel('Classification Accuracy')
        % Find maximuma Accuracy
        [maxAccuracy(i), ThresAccuracy(i)] = max(ROCObj.Metrics.Accuracy);
    end
end

%% Isolation Forest
% IForest was chosen to ignore due to the splitting method that is used
% when categorical variables have too many categories (64), since most of
% our features are differing, this is not usable and the accuracy of the
% classifier is too low

% To compensate for this, it was decided to use the TreeBagger feature
% selection method as a 3rd method
end

