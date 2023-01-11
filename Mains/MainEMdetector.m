% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

close all; clear all; clc

%% Load data
j = 0;
i = 1;
% First make the Folder Directory
MyFolder = '*Filepath to Dataset*';
% Now find all files in the folder and subfolders that have to be included
filePattern = fullfile(MyFolder,'**/*.*');
TheFiles = dir(filePattern);
% Delete subfolders themselves
TheFiles = TheFiles(16:end);
while i <= length(TheFiles)
    % Import the files
    FullFileName = fullfile(TheFiles(i).folder, TheFiles(i).name);
    % Load data
    fileID = fopen(FullFileName);
    if fileID == -1
        i = i+1;
        continue
    end
    load(FullFileName)
    if mod(i,14) == 0
        %% Global variables
        j = j+1;
        % Specify variables
        eog1 = eoglm2;
        eog2 = eogrm2;
        fs = readme.fs_original(1);
        % Find time array
        t = (1/fs):(1/fs):(length(eog1)/fs);
        hypnogramplt = repelem(hypnogram,30*fs);
        if length(hypnogramplt) > length(eog1)
            hypnogram = hypnogram(1:end-1);
            hypnogramplt = repelem(hypnogram,30*fs);
        end
        disp(j)
        %% Control variables
        VisRD = 0;
        VisPD = 0;
        %% Visualize raw data
        if VisRD == 1
            fig = figure; subplt1 = subplot(2,1,1); ylim(subplt1,[-3.5 1.5]); xlim(subplt1,[0 length(eog1)/fs]); plot(t,hypnogramplt,'Parent',subplt1);
            subplt2 = subplot(2,1,2); plot(t,eog1,'Parent',subplt2); hold on; plot(t,eog2,'Parent',subplt2);legend('Left EOG','Right EOG','Location','northwest');xlim(subplt2,[0 length(eog1)/fs]);ylim(subplt2,[-1000 1000]);
            handle = axes(fig,'Visible','off'); handle.Title.Visible='on';handle.XLabel.Visible='on';handle.YLabel.Visible='on';
            set(subplt2,'XTickLabel',{0:(length(eog1)/fs)});set(subplt1,'XTickLabel',{[]}) ;yticks(subplt1,[-3 -2 -1 0 1]);set(subplt1,'YTickLabel',{'N3','N2','N1','REM','W'})
            xlabel(handle,'Time (h)'); ylabel(handle,'Current (mV)'); title(handle,'Visualization of raw data');
        end
        %% Preprocessing step 1: High-pass filter to delete offset
        [b1,a1] = butter(2,0.3/fs,'high');
        eog1filt = filtfilt(b1,a1,eog1); eog2filt = filtfilt(b1,a1,eog2);
        %% Preprocessing step 2: Low-pass filter to have only relevant frequencies remain
        [b2,a2] = butter(2,35/fs,'low');
        eog1filt = filtfilt(b2,a2,eog1filt); eog2filt = filtfilt(b2,a2,eog2filt);
        %% Preprocessing step 3: Notch filter to delete electricity net influence
        [b3, a3] = butter(2,[48/fs 52/fs],'stop');
        eog1filt = filtfilt(b3,a3,eog1filt); eog2filt = filtfilt(b3,a3,eog2filt);
        %% Visualize preprocessed data
        if VisPD == 1
            fig2 = figure; axis manual; subplt1 = subplot(3,1,1); hypnogramplt = repelem(hypnogram,30*fs);
            ylim(subplt1,[-4 2]); xlim(subplt1,[0 length(hypnogramplt)]); plot(t,hypnogramplt,'Parent',subplt1);
            subplt2 = subplot(3,1,3); plot(eog1filt,'Parent',subplt2); hold on; plot(eog2filt,'Parent',subplt2);ylim(subplt2,[-1000 1000]);xlim(subplt2,[0 length(eog1)]);legend('Pre-processed left EOG signal','Pre-processed right EOG signal','Location','northwest');
            subplt3 = subplot(3,1,2); plot(t,eog1,'Parent',subplt3); hold on; plot(t,eog2,'Parent',subplt3);legend('Raw left EOG signal','Raw right EOG signal','Location','northwest');xlim(subplt3,[0 length(eog1)/fs]);ylim(subplt3,[-1000 1000]);
            handle = axes(fig2,'Visible','off'); handle.Title.Visible='on';handle.XLabel.Visible='on';handle.YLabel.Visible='on';
            set(subplt2,'XTickLabel',{0:(length(eog1)/fs)});set(subplt1,'XTickLabel',{[]});set(subplt3,'XTickLabel',{[]}) ;yticks(subplt1,[-3 -2 -1 0 1]);set(subplt1,'YTickLabel',{'N3','N2','N1','REM','W'})
            xlabel(handle,'Time (h)'); ylabel(handle,'Current (mV)'); title(handle,'Raw and pre-processed data');
        end
        %% Cut data from LightsOff to LightsOn (only relevant data is necessary)
        % Remove results that are not included in the manual sleep scoring
        MyFolderEvents = '*Filepath to scorings from sleep expert*';
        % Now find all files in the folder and subfolders that have to be included
        filePatternEvents = fullfile(MyFolderEvents, '*.txt');
        TheFilesEvents = dir(filePatternEvents);
        % Import the files
        baseFileNameEvents = TheFilesEvents(j).name;
        FullFileNameEvents = fullfile(TheFilesEvents(j).folder, baseFileNameEvents);
        EventData = importdata(FullFileNameEvents);
        % Find all data points that are logged with an EM, WEM, SEM, or REM
        isEMscoring = cellfun(@(x)isequal(x,'StartEMscoring'),EventData.textdata);
        isEMscoring2 = cellfun(@(x)isequal(x,'StopEMscoring'),EventData.textdata);
        [EventDataEMscoringStart, ~] = find(isEMscoring);
        [EventDataEMscoringStop, ~] = find(isEMscoring2);
        % Cut the original data to the correct size
        EventDataEMscoringStart = EventData.data(EventDataEMscoringStart,1);
        EventDataEMscoringStop = EventData.data(EventDataEMscoringStop,1);
        ToCutBeginExcess = mod(EventDataEMscoringStart,(fs*30));
        ToCutEndExcess = mod(EventDataEMscoringStop,(fs*30));
        EventDataEMscoringStart = EventDataEMscoringStart - ToCutBeginExcess -(fs*30);
        EventDataEMscoringStop = EventDataEMscoringStop - ToCutEndExcess + (fs*30);
        eog1filt = eog1filt(EventDataEMscoringStart+1:EventDataEMscoringStop);
        eog2filt = eog2filt(EventDataEMscoringStart+1:EventDataEMscoringStop);
        eog1 = eog1(EventDataEMscoringStart+1:EventDataEMscoringStop);
        eog2 = eog2(EventDataEMscoringStart+1:EventDataEMscoringStop);
        if EventDataEMscoringStop/(fs*30) < length(hypnogram)
            hypnogram = hypnogram((EventDataEMscoringStart/(fs*30)):EventDataEMscoringStop/(fs*30));
        else
            EventDataEMscoringStop = length(hypnogram)*fs*30;
            hypnogram = hypnogram((EventDataEMscoringStart/(fs*30)):EventDataEMscoringStop/(fs*30));
        end
            hypnogramplt = repelem(hypnogram,30*fs);
        while length(hypnogramplt) > length(eog1)
            hypnogram = hypnogram(1:end-1);
            hypnogramplt = repelem(hypnogram,30*fs);
        end
        while length(hypnogramplt) < length(eog1)
            hypnogram = [hypnogram; 1];
            hypnogramplt = repelem(hypnogram,30*fs);
        end
        %% Construct 30s epochs (for now only EOG, later possibly EEG as well)
        eog130s = reshape(eog1filt, [30*fs, (length(hypnogram))]);
        eog230s = reshape(eog2filt, [30*fs, (length(hypnogram))]);
        %% EM detector
        [EM, REM, SEM, EMAm, REMAm, SEMAm, EventDetectionBehavior{j}, EMManSEMs{j}, EMManREMs{j},EMManEMs{j},EMDetSEMs{j},EMDetREMs{j},EMDetEMs{j}] = EMdetector(EventDataEMscoringStart, hypnogram, eog1, eog2, eog1filt, eog2filt, fs, 0, 1, j, 2);
        HypnogramAll{j} = hypnogramplt;
        fprintf('EM detector is DONE...')
    end
    i = i+1;
end
%% Calculate accuracy of EM detector
EDBAll = zeros(3,4);
for o = 1:size(EventDetectionBehavior,2)
    EDBSub = EventDetectionBehavior{1,o};
    EDBAll = EDBAll + EDBSub;
end
% Calculate arrays for ANOVA calculation
DetEM = 0;
DetREM = 0;
DetSEM = 0;
ManEM = 0;
ManREM = 0;
ManSEM = 0;
Hypnograms = 0;
for o = 1:size(EMDetEMs,2)
    DetEMSub = EMDetEMs{1,o};
    DetEM = [DetEM; DetEMSub];
    DetREMSub = EMDetREMs{1,o};
    DetREM = [DetREM; DetREMSub];
    DetSEMSub = EMDetSEMs{1,o};
    DetSEM = [DetSEM; DetSEMSub];
    ManEMSub = EMManEMs{1,o};
    ManEM = [ManEM; ManEMSub];
    ManREMSub = EMManREMs{1,o};
    ManREM = [ManREM; ManREMSub];
    ManSEMSub = EMManSEMs{1,o};
    ManSEM = [ManSEM; ManSEMSub];
    HypnogramSub = HypnogramAll{1,o};
    Hypnograms = [Hypnograms; HypnogramSub];
end
% Delete zeros in the beginning
DetEM = DetEM(2:end);
DetREM = DetREM(2:end);
DetSEM = DetSEM(2:end);
ManEM = ManEM(2:end);
ManREM = ManREM(2:end);
ManSEM = ManSEM(2:end);
Hypnograms = Hypnograms(2:end);

HelleEMsW = 0; HelleEMsR = 0; HelleEMsN1 = 0; HelleEMsN2 = 0; HelleEMsN3 = 0;
HelleSEMsW = 0; HelleSEMsR = 0; HelleSEMsN1 = 0; HelleSEMsN2 = 0; HelleSEMsN3 = 0;
HelleREMsW = 0; HelleREMsR = 0; HelleREMsN1 = 0; HelleREMsN2 = 0; HelleREMsN3 = 0;

FabioEMsW = 0; FabioEMsR = 0; FabioEMsN1 = o; FabioEMsN2 = 0; FabioEMsN3 = 0;
FabioSEMsW = 0; FabioSEMsR = 0; FabioSEMsN1 = o; FabioSEMsN2 = 0; FabioSEMsN3 = 0;
FabioREMsW = 0; FabioREMsR = 0; FabioREMsN1 = o; FabioREMsN2 = 0; FabioREMsN3 = 0;

DetectorEMsW = 0; DetectorEMsR = 0; DetectorEMsN1 = 0; DetectorEMsN2 = 0; DetectorEMsN3 = 0;
DetectorSEMsW = 0; DetectorSEMsR = 0; DetectorSEMsN1 = 0; DetectorSEMsN2 = 0; DetectorSEMsN3 = 0;
DetectorREMsW = 0; DetectorREMsR = 0; DetectorREMsN1 = 0; DetectorREMsN2 = 0; DetectorREMsN3 = 0;

% Find amount of events during every sleep stage 
for i = 1:length(Hypnograms)
   if Hypnograms(i) == 1
       HelleEMsW = HelleEMsW + ManEM(i);
       HelleSEMsW = HelleSEMsW + ManSEM(i);
       HelleREMsW = HelleREMsW + ManREM(i);
       FabioEMsW = FabioEMsW + ManEMFabio(i);
       FabioSEMsW = FabioSEMsW + ManSEMFabio(i);
       FabioREMsW = FabioREMsW + ManREMFabio(i);
       DetectorEMsW = DetectorEMsW + DetEM(i);
       DetectorSEMsW = DetectorSEMsW + DetSEM(i);
       DetectorREMsW = DetectorREMsW + DetREM(i);
   elseif Hypnograms(i) == 0
       HelleEMsR = HelleEMsR + ManEM(i);
       HelleSEMsR = HelleSEMsR + ManSEM(i);
       HelleREMsR = HelleREMsR + ManREM(i);
       FabioEMsR = FabioEMsR + ManEMFabio(i);
       FabioSEMsR = FabioSEMsR + ManSEMFabio(i);
       FabioREMsR = FabioREMsR + ManREMFabio(i);
       DetectorEMsR = DetectorEMsR + DetEM(i);
       DetectorSEMsR = DetectorSEMsR + DetSEM(i);
       DetectorREMsR = DetectorREMsR + DetREM(i);
   elseif Hypnograms (i) == -1
       HelleEMsN1 = HelleEMsN1 + ManEM(i);
       HelleSEMsN1 = HelleSEMsN1 + ManSEM(i);
       HelleREMsN1 = HelleREMsN1 + ManREM(i);
       FabioEMsN1 = FabioEMsN1 + ManEMFabio(i);
       FabioSEMsN1 = FabioSEMsN1 + ManSEMFabio(i);
       FabioREMsN1 = FabioREMsN1 + ManREMFabio(i);
       DetectorEMsN1 = DetectorEMsN1 + DetEM(i);
       DetectorSEMsN1 = DetectorSEMsN1 + DetSEM(i);
       DetectorREMsN1 = DetectorREMsN1 + DetREM(i);
   elseif Hypnograms(i) == -2
       HelleEMsN2 = HelleEMsN2 + ManEM(i);
       HelleSEMsN2 = HelleSEMsN2 + ManSEM(i);
       HelleREMsN2 = HelleREMsN2 + ManREM(i);
       FabioEMsN2 = FabioEMsN2 + ManEMFabio(i);
       FabioSEMsN2 = FabioSEMsN2 + ManSEMFabio(i);
       FabioREMsN2 = FabioREMsN2 + ManREMFabio(i);
       DetectorEMsN2 = DetectorEMsN2 + DetEM(i);
       DetectorSEMsN2 = DetectorSEMsN2 + DetSEM(i);
       DetectorREMsN2 = DetectorREMsN2 + DetREM(i);
   elseif Hypnograms(i) == -3
       HelleEMsN3 = HelleEMsN3 + ManEM(i);
       HelleSEMsN3 = HelleSEMsN3 + ManSEM(i);
       HelleREMsN3 = HelleREMsN3 + ManREM(i);
       FabioEMsN3 = FabioEMsN3 + ManEMFabio(i);
       FabioSEMsN3 = FabioSEMsN3 + ManSEMFabio(i);
       FabioREMsN3 = FabioREMsN3 + ManREMFabio(i);
       DetectorEMsN3 = DetectorEMsN3 + DetEM(i);
       DetectorSEMsN3 = DetectorSEMsN3 + DetSEM(i);
       DetectorREMsN3 = DetectorREMsN3 + DetREM(i);
   end
end
% Calculate Accuracy, Sensitivity, Specificity, Precision, and F-score from TP,TN,FP,FN found
% for EM
EMAccu = (EDBAll(1,1) + EDBAll(1,2))/(EDBAll(1,1) + EDBAll(1,2) + EDBAll(1,3) + EDBAll(1,4));
EMSens = EDBAll(1,1)/(EDBAll(1,1) + EDBAll(1,4));
EMSpec = EDBAll(1,2)/(EDBAll(1,2) + EDBAll(1,3));
EMPrec = EDBAll(1,1)/(EDBAll(1,1) + EDBAll(1,3));
EMF = (2*EMPrec*EMSens)/(EMPrec+EMSens);
% Calculate Accuracy, Sensitivity, Specificity, Precision, and F-score from TP,TN,FP,FN found
% for REM
REMAccu = (EDBAll(2,1) + EDBAll(2,2))/(EDBAll(2,1) + EDBAll(2,2) + EDBAll(2,3) + EDBAll(2,4));
REMSens = EDBAll(2,1)/(EDBAll(2,1) + EDBAll(2,4));
REMSpec = EDBAll(2,2)/(EDBAll(2,2) + EDBAll(2,3));
REMPrec = EDBAll(2,1)/(EDBAll(2,1) + EDBAll(2,3));
REMF = (2*REMPrec*REMSens)/(REMPrec+REMSens);
% Calculate Accuracy, Sensitivity, Specificity, Precision, and F-score from TP,TN,FP,FN found
% for SEM
SEMAccu = (EDBAll(3,1) + EDBAll(3,2))/(EDBAll(3,1) + EDBAll(3,2) + EDBAll(3,3) + EDBAll(3,4));
SEMSens = EDBAll(3,1)/(EDBAll(3,1) + EDBAll(3,4));
SEMSpec = EDBAll(3,2)/(EDBAll(3,2) + EDBAll(3,3));
SEMPrec = EDBAll(3,1)/(EDBAll(3,1) + EDBAll(3,3));
SEMF = (2*SEMPrec*SEMSens)/(SEMPrec+SEMSens);