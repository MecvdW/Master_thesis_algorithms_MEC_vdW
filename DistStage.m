% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

function Perc = DistStage(data)
% First, calculate the amount of times a certain sleep stage occurs
Ones = sum(data(:)==1);
Zeros = sum(data(:)==0);
MinusOnes = sum(data(:)==-1);
MinusTwos = sum(data(:)==-2);
MinusThrees = sum(data(:)==-3);
% Calculate total amount of sleep stages
Total = Ones + Zeros + MinusOnes + MinusTwos + MinusThrees;
% Now calculate the percentages of the whole and put in a table
POnes = Ones/Total;
PZeros = Zeros/Total;
PMinusOnes = MinusOnes/Total;
PMinusTwos = MinusTwos/Total;
PMinusThrees = MinusThrees/Total;

Perc = [POnes; PZeros; PMinusOnes; PMinusTwos; PMinusThrees] * 100;
end