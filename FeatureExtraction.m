function [Out, Response] = FeatureExtraction(hypnogram, dataL,dataR,fs,EM,REM,SEM,EMAm,REMAm,SEMAm, DiagNumbers)
% First features in the time domain will be extracted, than features in the
% frequency domain will be extracted. All features will be put together
% into a table which can be used in feature selection algorithms

% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071

%% Extract features in the time domain
for i = 1:size(dataL,2)
    % Absolute mean of signal
    AbsMeanLeft(i) = AMOS(dataL(:,i)); AbsMeanRight(i) = AMOS(dataR(:,i));
    % Energy of signal
    EnergyLeft(i) = EPS(dataL(:,i),1); EnergyRight(i) = EPS(dataR(:,i),1);
    % Power of signal
    PowerLeft(i) = EPS(dataL(:,i),dataL(:,i)); PowerRight(i) = EPS(dataR(:,i),dataR(:,i));
    % Form factor of signal
    FormFLeft(i) = FFOS(dataL(:,i)); FormFRight(i) = FFOS(dataR(:,i));
    % Ratio of signal energy to previous window and next window
    if i == 1
        energyPL = 0; energyPR = 0; energyFL(i) = 0; energyFR(i) = 0;
    else
        energyPL = EnergyLeft(i-1); energyPR = EnergyRight(i-1); energyFL(i-1) = EnergyLeft(i); energyFR(i-1) = EnergyRight(i);
    end
    RPWLeft(i) = ROW(EnergyLeft(i),energyPL); RPWRight(i) = ROW(EnergyRight(i),energyPR);
    if i == 1
        continue
    else
        RFWLeft(i) = ROW(EnergyLeft(i-1),energyFL(i-1)); RFWRight(i) = ROW(EnergyRight(i-1),energyFR(i-1));
    end

    if RPWLeft(i) == Inf
        RPWLeft(i) = 0;
    elseif RPWRight(i) == Inf
        RPWRight(i) = 0;
    elseif RFWLeft(i) == Inf
        RFWLeft(i) = 0;
    elseif RFWRight(i) == Inf
        RFWRight(i) = 0;
    end

    if i == size(dataL,2)
        % Standard deviation of the signal
        StdLeft = STDOF(dataL,AbsMeanLeft); StdRight = STDOF(dataR,AbsMeanRight);
        % Skewness of the signal
        SkewnessLeft = KSOS(dataL,AbsMeanLeft,StdLeft,3); SkewnessRight = KSOS(dataR,AbsMeanRight,StdRight,3);
        % Kurtosis of the signal
        KurtosisLeft = KSOS(dataL,AbsMeanLeft,StdLeft,4); KurtosisRight = KSOS(dataR,AbsMeanRight,StdRight,4);
        % Ratio of signal energy to power of all epochs
        RSEAELeft = RSEAE(EnergyLeft,PowerLeft); RSEAERight = RSEAE(EnergyRight,PowerRight);
        % Ratio of signal energy to energy of all epochs
        RSEEELeft = RSE(EnergyLeft); RSEEERight = RSE(EnergyRight);
        %Ratio of signal form factor to form factor of all epochs
        RSFFELeft = RSE(FormFLeft); RSFFERight = RSE(FormFRight);
        % Ratio of signal form factor to form factor of both signals
        RSFFSLeft = RSS(FormFLeft,FormFRight); RSFFSRight = RSS(FormFRight,FormFLeft);
        % Ratio of signal standard deviation to standard deviation of all epochs
        RSTDELeft = RSE(StdLeft); RSTDERight = RSE(StdRight);
        % Ratio of signal standard deviation to standard deviation of all
        % signals
        RSTDSLeft = RSS(StdLeft,StdRight); RSTDSRight = RSS(StdRight,StdLeft);
    end
    % Correlation coefficient between Left and Right EOG signals
    CorrCoefLR{i} = corrcoef(dataL(:,i),dataR(:,i));
end
%% Investigation of sleep stage stability
% The sleep stage stability is investigated by calculating the amount
% of sleep stage transitions, the distribution of sleep stages in
% percentages, and the average length of a sleep stage (as a measure of
% the sleep stage stability)
[TransAmount, TransPos] = SStrans(hypnogram);
DistStages = DistStage(hypnogram);
LengthStages = StageLength(hypnogram,TransPos);

%% Results of EM detector
EMPres = ones(size(dataL,2),1);
REMPres = ones(size(dataL,2),1);
SEMPres = ones(size(dataL,2),1);
for i = 1:size(dataL,2)
    if isempty(EM)
        % Presence of EMs
        EMPres(i) = 0;
    elseif isempty(REM)
        % Presense of REMs
        REMPres(i) = 0;
    elseif isempty(SEM)
        % Presense of SEMs
        SEMPres(i) = 0;
    end
end

%% Extract features in the frequency domain
for i = 1:size(dataL,2)
    % Energy of the epoch
    EnergyFreqLeft(:,i) = EnergyAll(dataL(:,i)); EnergyFreqRight(:,i) = EnergyAll(dataR(:,i));
    % Energy of the epoch, frequency band 0-2Hz[Es,f,indxs]
    [EnergyFreqLeft02(:,i),fFreqLeft02(:,i),indxsFreqLeft02(:,i)]= Energy(dataL(:,i),[0 2],fs); [EnergyFreqRight02(:,i),fFreqRight02(:,i),indxsFreqRight02(:,i)]= Energy(dataR(:,i),[0 2],fs);
    % Energy of the epoch, frequency band 2-4Hz
    [EnergyFreqLeft24(:,i),fFreqLeft24(:,i),indxsFreqLeft24(:,i)]= Energy(dataL(:,i),[2 4],fs); [EnergyFreqRight24(:,i),fFreqRight24(:,i),indxsFreqRight24(:,i)] = Energy(dataR(:,i),[2 4],fs);
    if i == size(dataL,2)
        % Relative energy in 0-2Hz frequency band (energy of signal/energy of all epochs)
        REn02ELeft = REE(EnergyFreqLeft02); REn02ERight = REE(EnergyFreqRight02);
        % Relative energy in 0-2Hz frequency band (energy of signal/energy of all signals)
        REn02SLeft = RES(EnergyFreqLeft02,EnergyFreqRight02); REn02SRight = RES(EnergyFreqRight02,EnergyFreqLeft02);
        % Relative energy in 2-4Hz frequency band (energy of signal/energy of all epochs)
        REn24ELeft = REE(EnergyFreqLeft24); REn24ERight = REE(EnergyFreqRight24);
        % Relative energy in 2-4Hz frequency band (energy of signal/energy of all signals)
        REn24SLeft = RES(EnergyFreqLeft24,EnergyFreqRight24); REn24SRight = RES(EnergyFreqRight24,EnergyFreqLeft24);
        % Absolute mean of signals in frequency domain
        FreqMean = AMF(EnergyFreqLeft,EnergyFreqRight);
        % Absolute standard deviation of signals in frequency domain
        FreqStd = ASTDF(EnergyFreqLeft, EnergyFreqRight, FreqMean);
    end
end

%% Features that need to be changed first
% Frequency energies
maxEnergyFreqLeft02 = max(abs(real(EnergyFreqLeft02)),[],1); maxEnergyFreqRight02 = max(abs(real(EnergyFreqRight02)),[],1);
maxEnergyFreqLeft24 = max(abs(real(EnergyFreqLeft24)),[],1); maxEnergyFreqRight24 = max(abs(real(EnergyFreqRight24)),[],1);

% Relative energies
maxREn02ELeft = max(abs(real(REn02ELeft)),[],1); maxREn02ERight = max(abs(real(REn02ERight)),[],1);
maxREn02SLeft = max(abs(real(REn02SLeft)),[],1); maxREn02SRight = max(abs(real(REn02SRight)),[],1);
maxREn24ELeft = max(abs(real(REn24ELeft)),[],1); maxREn24ERight = max(abs(real(REn24ERight)),[],1);
maxREn24SLeft = max(abs(real(REn24SLeft)),[],1); maxREn24SRight = max(abs(real(REn24SRight)),[],1);

% Amount of sleep stage transitions
ArrayTransAmount = ones(size(hypnogram))*TransAmount;

% Distribution of sleep stages
ArrayDistStages = ones(length(DistStages),length(hypnogram)).*DistStages;

% Length of sleep stages
ArrayLengthStages = ones(length(LengthStages),length(hypnogram)).*LengthStages;

% Correlation coefficients
for i = 1:length(hypnogram)
    mat = CorrCoefLR{i};
    if isempty(mat)
        CorrCoefNmr(i) = 0;
    else
        CorrCoefNmr(i) = mat(2,1);
    end

    % Hypnogram
    if hypnogram(i) == 1
        hypnogramltrs(i)  = "W";
    elseif hypnogram(i)  == 0
        hypnogramltrs(i)  = "REM";
    elseif hypnogram(i)  == -1
        hypnogramltrs(i)  = "N1";
    elseif hypnogram(i)  == -2
        hypnogramltrs(i)  = "N2";
    else
        hypnogramltrs(i)  = "N3";
    end
end
% Add diagnosis of patient to table of features
% Add diagnosis of patient to table of features
DiagNumbers = table2array(DiagNumbers);
if DiagNumbers(1,1) == 1 && DiagNumbers(1,2) == 1
    Diagnosis = "PD+RBD";
elseif DiagNumbers(1,1) == 1 && DiagNumbers(1,2) == 0
    Diagnosis = "PD-RBD";
elseif DiagNumbers(1,1) == 0 && DiagNumbers(1,2) == 1
    Diagnosis = "RBD";
else
    Diagnosis = "HS";
end
Diagnosis = repelem((Diagnosis),(length(hypnogram)));
%% Make a table of features for feature selection
tableArray = [Diagnosis; hypnogramltrs; AbsMeanLeft; AbsMeanRight; EnergyLeft; EnergyRight; PowerLeft; PowerRight; FormFLeft; FormFRight; StdLeft; StdRight; SkewnessLeft; SkewnessRight; KurtosisLeft; KurtosisRight; RPWLeft; RPWRight; RFWLeft; RFWRight; RSEAELeft; RSEAERight; RSEEELeft; RSEEERight; RSFFELeft; RSFFERight; RSFFSLeft; RSFFSRight; RSTDELeft; RSTDERight; RSTDSLeft; RSTDSRight; ArrayTransAmount'; ArrayDistStages; ArrayLengthStages; CorrCoefNmr; maxEnergyFreqLeft02; maxEnergyFreqRight02; maxEnergyFreqLeft24; maxEnergyFreqRight24; maxREn02ELeft; maxREn02ERight; maxREn02SLeft; maxREn02SRight; maxREn24ELeft; maxREn24ERight; maxREn24SLeft; maxREn24SRight; real(FreqMean); real(FreqStd);EMPres';REMPres';SEMPres';EMAm';REMAm';SEMAm'];
Out = array2table(tableArray','VariableNames',{'Diagnosis','Sleep Stages','Mean of Signal left(t)','Mean of Signal right(t)','Energy of Signal left','Energy of Signal right','Power of Signal left','Power of Signal right','Form Factor of Signal left','Form Factor of Signal right','STD of Signal left(t)','STD of Signal right(t)','Skewness of Signal left','Skewness of Signal right','Kurtosis of Signal left','Kurtosis of Signal right', ...
    'Ratio of Energy to previous window left','Ratio of Energy to previous window right','Ratio of Energy to next window left','Ratio of Energy to next window right','Ratio of Energy to all epochs left','Ratio of Energy to all epochs right','Ratio of Energy to all Signals left','Ratio of Energy to all Signals right','Ratio of Form Factor to all epochs left', 'Ratio of Form Factor to all epochs right',...
    'Ratio of Form Factor to all Signals left','Ratio of Form Factor to all Signals right','Ratio of STD to all epochs left','Ratio of STD to all epochs right','Ratio of STD to all Signals left','Ratio of STD to all Signals right','Sleep stage transitions','Distribution of sleep stages, W','Distribution of sleep stages, REM','Distribution of sleep stages, N1','Distribution of sleep stages, N2','Distribution of sleep stages, N3','Average length of sleep stages, W','Average length of sleep stages, REM','Average length of sleep stages, N1','Average length of sleep stages, N2','Average length of sleep stages, N3', ...
    'Correlation coefficient','Energy of Signal 0-2Hz left','Energy of Signal 0-2Hz right','Energy of Signal 2-4Hz left','Energy of Signal 2-4Hz right','Relative energy to all epochs 0-2Hz left','Relative energy to all epochs 0-2Hz right','Relative energy to all Signals 0-2Hz left','Relative energy to all Signals 0-2Hz right','Relative energy to all epochs 2-4Hz left','Relative energy to all epochs 2-4Hz right','Relative energy to all Signals 2-4-Hz left','Relative energy to all Signals 2-4-Hz right', ...
    'Mean of Signal (f)','STD of Signal (f)','Presence of EMs','Presence of REMs','Presence of SEMs','Amount of EMs','Amount of REMs','Amount of SEMs'});
Response = Diagnosis;
end