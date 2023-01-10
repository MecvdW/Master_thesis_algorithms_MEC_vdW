% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

function Lengths = StageLength(data,position)
pos = find(position);
Ones = [];
Zeros = [];
MinusOnes = [];
MinusTwos = [];
MinusThrees = [];
for i = 1:length(pos)
    % First, determine the stage that is entered when there is a new stage
    if i == 1
        Stage(i) = data(1);
    else
        Stage(i) = data(pos(i));
    end
    % Now, determine the length of each stage
    if i == 1
        Length(i) = pos(i);
    else
        Length(i) = pos(i)-pos(i-1);
    end
    % Separate the stage lengths
    if Stage(i) == 1
        Ones = [Ones; Length(i)];
    elseif Stage(i) == 0
        Zeros = [Zeros; Length(i)];
    elseif Stage(i) == -1
        MinusOnes = [MinusOnes; Length(i)];
    elseif Stage(i) == -2
        MinusTwos = [MinusTwos; Length(i)];
    else
        MinusThrees = [MinusThrees; Length(i)];
    end
end
AveOnes = mean(Ones);
AveZeros = mean(Zeros);
AveMinusOnes = mean(MinusOnes);
AveMinusTwos = mean(MinusTwos);
AveMinusThrees = mean(MinusThrees);

Lengths = [AveOnes; AveZeros; AveMinusOnes; AveMinusTwos; AveMinusThrees];
end