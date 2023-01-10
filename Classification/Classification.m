% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

function Result = Classification(Classifier,OutTest, ResponseVarTest)
% First classify the test data using the classifier
[Result, Scores] = predict(Classifier,OutTest);
% Calculate ROC metrics and AUC values for all three classes
rocObj = rocmetrics(ResponseVarTest,Scores,Classifier.ClassNames);
AUCValues = rocObj.AUC;
% Plot ROC metrics
figure;
plot(rocObj);
end