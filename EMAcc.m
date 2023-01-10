% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

function [Accuracy, Sensitivity, Specificity, TP, TN, FP, FN,EventStage] = EMAcc(EventsMan, EventsDet,hypnogramplt, class)
% First, find the amount of true positives, true negatives, false positives
% , and false negatives, after which the accuracy, sensitivity, and
% specificity can be calculated
TP = 0;
TN = 0;
FP = 0;
FN = 0;
EventStage = zeros(length(EventsMan),2);
for i = 1:length(hypnogramplt)
    if EventsDet(i) == class && EventsMan(i) == EventsDet(i)
        TP = TP + 1;
        EventStage(i,1) = 1; 
    elseif EventsMan(i) == EventsDet(i)
        TN = TN + 1;
        EventStage(i,1) = 2;
    elseif EventsDet(i) == class && EventsMan(i) ~= class
        FP = FP + 1;
        EventStage(i,1) = 3;
    else
        FN = FN + 1;
        EventStage(i,1) = 4;
    end
end
% Calculate Accuracy
Accuracy = (TP + TN)/(TP + TN + FP + FN);
% Calculate Sensitivity
Sensitivity = TP / (TP+FN);
% Calculate Specificity
Specificity = TN/(TN + FP);
end