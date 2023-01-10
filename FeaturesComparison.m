% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

function [Features, Response] = FeaturesComparison(hypnogram, LightsOff, LightsOn,fs, ChinData,DiagNumbers)
% Sleep Onset Latency in minutes
Sleep = find(hypnogram~=1);
Asleep = Sleep(1);
Awake = Sleep(end);
SOL = (Awake-Asleep)/2;
% Wake After Sleep Onset in minutes
WakeInRecording = find(hypnogram==1);
WASO = sum(WakeInRecording)/60;
% Total Sleep Time in hours
SleepTime = hypnogram(Asleep:Awake);
TST = length(SleepTime)/(60*60);
% Time in Bed in hours
TiB = (LightsOff - LightsOn)/(60*60);
% Sleep Efficiency in percentages
SE = TST/TiB * 100;
% Arousal Index (N1 --> W & REM --> W)
for i = 1:length(hypnogram) -1
    if hypnogram(i) ~= hypnogram(i+1) && (hypnogram(i+1) == 1 && hypnogram(i) == 0) || (hypnogram(i) == -1 && hypnogram(i) == 0)
        ARIs(i) = 1;
    else
        ARIs(i) = 0;
    end
end
ARI = sum(ARIs);
% Minutes of REM Sleep
hypnogramAsleep = hypnogram(Asleep:Awake);
REMSleep = find(hypnogramAsleep==0);
MREM = sum(REMSleep)/60;
% Proportion of N1 Sleep
N1Sleep = find(hypnogramAsleep==-1);
PN1 = (sum(N1Sleep)/(60*60))/TST;
% Proportion of N2 Sleep
N2Sleep = find(hypnogramAsleep==-2);
PN2 = (sum(N2Sleep)/(60*60))/TST;
% Proportion of N3 Sleep
N3Sleep = find(hypnogramAsleep==-3);
PN3 = (sum(N3Sleep)/(60*60))/TST;
% Proportion of REM Sleep
PNR = (MREM/60)/TST;
% NREM Fragmentation Index
for i = 1:length(hypnogram) -1
    if hypnogram(i) ~= hypnogram(i+1) && (hypnogram(i+1) == -1 || hypnogram(i+1) == -2 || hypnogram(i+1) == -3) && (hypnogram(i) == -1 || hypnogram(i) == -2 || hypnogram(i) == -3)
        Transs(i) = 1;
    else
        Transs(i) = 0;
    end
end
Trans = sum(Transs);
NFI = Trans/((PN1*TST)+(PN2*TST)+(PN3*TST));
% REM Fragmentation Index
for i = 1:length(hypnogram) -1
    if hypnogram(i) ~= hypnogram(i+1) && hypnogram(i) == 0 && (hypnogram(i+1) == -1 || hypnogram(i+1) == -2 || hypnogram(i+1) == -3)
        TransREM(i) = 1;
    else
        TransREM(i) = 0;
    end
end
Transrem = sum(TransREM);
RFI = Transrem/(MREM/60);
% Wake Proportion
Wakes = find(hypnogramAsleep==1);
Wake = sum(Wakes)/(60*60);
WP = Wake/TST;
% Sleep Transition Index
for i = 1:length(hypnogram) -1
    if hypnogram(i) ~= hypnogram(i+1) && hypnogram(i) == 0 && (hypnogram(i+1) == -1 || hypnogram(i+1) == -2 || hypnogram(i+1) == -3)
        TransREMs(i) = 1;
    elseif hypnogram(i) ~= hypnogram(i+1) && hypnogram(i+1) == 0 && (hypnogram(i) == -1 || hypnogram(i) == -2 || hypnogram(i) == -3)
        TransREMs(i) = 1;
    else
        TransREMs(i) = 0;
    end
end
Transrems = sum(TransREMs)/(60*60);
STI = Transrems/TST;
% First find state transition positions and which states are changing
for i = 1:length(hypnogram) -1
    if hypnogram(i) ~= hypnogram(i+1)
        TransPos(i) = 1;
    else
        TransPos(i) = 0;
    end
end
LengthStages = StageLength(hypnogram,TransPos);
% Average Length N1
ALN1 = LengthStages(3);
% Average Length N2
ALN2 = LengthStages(4);
% Average Length N3
ALN3 = LengthStages(5);
% Average Length REM
ALREM = LengthStages(2);
% REM Sleep Atonia Index
for i = 1:length(REMSleep)
    k=0;
    period = REMSleep(i)*fs:REMSleep(i)*fs+fs*30-1;
    for j = 1:fs:length(period)
        k = k+1;
        % Find mean amplitude of Chin EMG
        AverageValue = mean(abs(ChinData(period(j):period(j)+fs-1)));
        if AverageValue <= 1
            Atonia(k) = 1;
        else
            Atonia(k) = 0;
        end
        % Calculate the mean frequency of the EMG data during REM sleep
        MeanFreq(k) = meanfreq(ChinData(period(j):period(j)+fs-1),fs);
        % Calculate the median frequency of the EMG data during REM sleep
        MedianFreq(k) = medfreq(ChinData(period(j):period(j)+fs-1));
        % Calculate Spectral Edge Frequency at 95% during REM sleep
        [p,f] = pspectrum(ChinData(period(j):period(j)+fs-1));
        r = 1;
        while r < length(p)
            SEFsum = sum(p(1:r))/sum(p);
            if SEFsum >= 0.95
                SEF(k) = f(r);
                break
            else
                r = r+1;
            end
        end
    end
    RAI(i,:) = Atonia;
    MeanFreqs(i,:) = MeanFreq;
    MedianFreqs(i,:) = MedianFreq;
    SEFs(i,:) = SEF;
end
% Change the hypnogram array to letters
hypnogram = repelem(hypnogram,30);
for i = 1:length(hypnogram)
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
% Final table with all features has to be per 1s in the data
SOL = ones(length(hypnogram),1)*SOL;
WASO = ones(length(hypnogram),1)*WASO;
TiB = ones(length(hypnogram),1)*TiB;
TST = ones(length(hypnogram),1)*TST;
SE = ones(length(hypnogram),1)*SE;
ARI = ones(length(hypnogram),1)*ARI;
MREM = ones(length(hypnogram),1)*MREM;
PN1 = ones(length(hypnogram),1)*PN1;
PN2 = ones(length(hypnogram),1)*PN2;
PN3 = ones(length(hypnogram),1)*PN3;
PNR = ones(length(hypnogram),1)*PNR;
NFI = ones(length(hypnogram),1)*NFI;
RFI = ones(length(hypnogram),1)*RFI;
WP = ones(length(hypnogram),1)*WP;
STI = ones(length(hypnogram),1)*STI;
ALN1 = ones(length(hypnogram),1)*ALN1;
ALN2 = ones(length(hypnogram),1)*ALN2;
ALN3 = ones(length(hypnogram),1)*ALN3;
ALREM = ones(length(hypnogram),1)*ALREM;
% Now change all matrices to arrays
RAIREM = reshape(RAI.',1,[]);
MeanFreqsREM = reshape(MeanFreqs.',1,[]);
MedianFreqsREM = reshape(MedianFreqs.',1,[]);
SEFsREM = reshape(SEFs.',1,[]);
RAI = zeros(length(hypnogram),1);
MeanFreqs = zeros(length(hypnogram),1);
MedianFreqs = zeros(length(hypnogram),1);
SEFs = zeros(length(hypnogram),1);
m = 0;
for k = 1:length(hypnogram)
    if hypnogram(k) == 0
        m = m+1;
        RAI(k) = RAIREM(m);
        MeanFreqs(k) = MeanFreqsREM(m);
        MedianFreqs(k) = MedianFreqsREM(m);
        SEFs(k) = SEFsREM(m);
    end
end
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
%% Everything together in an output table
tableArray = [Diagnosis; hypnogramltrs; SOL'; WASO'; TST'; TiB'; SE'; ARI'; MREM'; PN1'; PN2'; PN3'; PNR'; NFI'; RFI'; WP'; STI'; ALN1'; ALN2'; ALN3'; ALREM'; RAI'; MeanFreqs'; MedianFreqs'; SEFs'];
Features = array2table(tableArray','VariableNames',{'Diagnosis','Hypnogram','Sleep Onset Latency','Wake After Sleep Onset','Total Sleep Time','Time in Bed','Sleep Efficiency','Arousal Index','Minutes of REM Sleep',...
    'Proportion of N1 Sleep','Proportion of N2 Sleep','Proportion of N3 Sleep','Proportion of REM Sleep','NREM Fragmentation Index','REM Fragmentation Index','Wake Proportion',...
    'Sleep Transition Index','Average Length N1','Average Length N2','Average Length N3','Average Length REM','REM Sleep Atonia Index','Mean Frequency of REM mini-epochs',...
    'Median Frequency of REM mini-epochs','Spectral Edge Frequency at 95% of REM mini-epochs'});
Response = Diagnosis;
end