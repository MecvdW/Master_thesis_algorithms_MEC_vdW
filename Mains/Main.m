% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

close all; clear all; clc

%% Load data
j = 4;
% First make the Folder Directory
MyFolder = 'D:\MasterThesis\GlostrupRBD';
% Now find all files in the folder and subfolders that have to be included
filePattern = fullfile(MyFolder,'**/*.*');
TheFiles = dir(filePattern);
% Delete subfolders themselves
TheFiles = TheFiles(223:end);
% Delete file where it crashed
TheFiles = TheFiles(1:518);
% Load file with diagnosis information
DiagnosisFileName = fullfile(TheFiles(1).name);
DiagnosisFullName = fullfile(TheFiles(1).folder,DiagnosisFileName);
DiagnosisFile = readtable(DiagnosisFullName);
% Get necessary columns
DiagnosisFile = DiagnosisFile(:,[1,13,14]);
% Import the files and change the names to not mix them up
for i = 4:5:length(TheFiles)
    j = j+1;
    FullFileName = fullfile(TheFiles(i).folder);
    % Find diagnosis classification
    DiagFile = extractAfter(FullFileName,'GlostrupRBD\');
    DiagnosisNames = table2cell(DiagnosisFile(:,1));
    Diagloc = find(strcmp(DiagFile,DiagnosisNames));
    DiagNumbers = DiagnosisFile(Diagloc,2:3);
    % Load data
    [header, data, hypnogram, loo] = dcsm_data_read(FullFileName, 0, {'EOGR','EOGL'});
    % Extract specific data needed
    eog1loc = find(contains(cellstr(header.channels), 'EOGL'));
    eog2loc = find(contains(cellstr(header.channels), 'EOGR'));
    if isempty(eog1loc) || isempty(eog2loc)
        fprintf('Missing file, skip patient')
        continue
    end
    eog1 = data{eog1loc,:}';
    eog2 = data{eog2loc,:}';
    LightsOff = loo.Lights_off;
    LightsOn = loo.Lights_on;
    if header.hdr.numbersperrecord(1) == header.hdr.numbersperrecord(2)
        fs = header.hdr.numbersperrecord(1);
    else
        fprintf('fs is not the same')
    end
    disp(j)
    %% Global variables
    t = (1/fs):(1/fs):(length(eog1)/fs);
    hypnogramplt = repelem(hypnogram,30*fs);
    if length(hypnogramplt) > length(eog1)
        hypnogram = hypnogram(1:end-1);
        hypnogramplt = repelem(hypnogram,30*fs);
    end
    %% Control variables
    VisRD = 1;
    VisPD = 1;
    %% Visualize raw data
    if VisRD == 1
        fig = figure; subplt1 = subplot(2,1,1); ylim(subplt1,[-3.5 1.5]); xlim(subplt1,[0 length(eog1)/fs]); plot(t,hypnogramplt,'Parent',subplt1);
        subplt2 = subplot(2,1,2); plot(t,eog1,'Parent',subplt2); hold on; plot(t,eog2,'Parent',subplt2);legend('Left EOG','Right EOG');xlim(subplt2,[0 length(eog1)/fs]);
        handle = axes(fig,'Visible','off'); handle.Title.Visible='on';handle.XLabel.Visible='on';handle.YLabel.Visible='on';
        %xticklabels = 0:(length(eog1)/fs); xticks(subplt2,xticklabels)
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
        subplt2 = subplot(3,1,3); plot(eog1filt,'Parent',subplt2); hold on; plot(eog2filt,'Parent',subplt2);ylim(subplt2,[-2000 2000]);xlim(subplt2,[0 length(eog1)]);legend('Pre-processed left EOG signal','Pre-processed right EOG signal','Location','northwest');
        subplt3 = subplot(3,1,2); plot(t,eog1,'Parent',subplt3); hold on; plot(t,eog2,'Parent',subplt3);legend('Raw left EOG signal','Raw right EOG signal','Location','northwest');xlim(subplt3,[0 length(eog1)/fs]);ylim(subplt3,[-2000 2000]);
        handle = axes(fig2,'Visible','off'); handle.Title.Visible='on';handle.XLabel.Visible='on';handle.YLabel.Visible='on';
        set(subplt2,'XTickLabel',{0:(length(eog1)/fs)});set(subplt1,'XTickLabel',{[]});set(subplt3,'XTickLabel',{[]}) ;yticks(subplt1,[-3 -2 -1 0 1]);set(subplt1,'YTickLabel',{'N3','N2','N1','REM','W'})
        xlabel(handle,'Time (h)'); ylabel(handle,'Current (mV)'); title(handle,'Raw and pre-processed data');
    end
    %% Cut data from LightsOff to LightsOn (only relevant data is necessary)
    ToCutBeginExcess = mod(LightsOff,(30));
    ToCutEndExcess = mod(LightsOn,(30));
    Begin = LightsOff - ToCutBeginExcess;
    End = LightsOn + ((30)-ToCutEndExcess);
    if End > (length(eog1)/fs)
        fprintf('File dimensions wrong')
        continue
    end
    if (End/30) > length(hypnogram)
        fprintf('File dimensions wrong')
        continue
    end
    eog1filt = eog1filt((Begin*fs)+1:(End*fs));
    eog2filt = eog2filt((Begin*fs)+1:(End*fs));
    eog1 = eog1((Begin*fs)+1:(End*fs));
    eog2 = eog2((Begin*fs)+1:(End*fs));
    hypnogram = hypnogram((Begin/30)+1:(End/30));
    %% Construct 30s epochs (for now only EOG, later possibly EEG as well)
    eog130s = reshape(eog1filt, [30*fs, (length(hypnogram))]);
    eog230s = reshape(eog2filt, [30*fs, (length(hypnogram))]);
    %% EM detector
    [EM, REM, SEM, EMAm, REMAm, SEMAm, EventDetectionBehavior{j}] = EMdetector(hypnogram, eog1, eog2, eog1filt, eog2filt, fs, 0, 0, i, 1);
    fprintf('EM detector is DONE...')
    %% Feature extraction
    [Out, Responsevar] = FeatureExtraction(hypnogram, eog130s,eog230s,fs,EM,REM,SEM,EMAm,REMAm,SEMAm, DiagNumbers);

    OutAll{j} = Out;
    ResponsevarAll{j} = Responsevar;

    fprintf('Feature Extraction is DONE...')
end
save('OutAll.mat','OutAll', '-v7.3')
save('ResponsevarAll.mat','ResponsevarAll')
%% Division of data into training data and test data
% Put all training data together, 70% of the data will be used for training
OutTraining = array2table(zeros(1,size(OutAll{1,4},2)),'VariableNames',{'Diagnosis','Sleep Stages','Mean of Signal left(t)','Mean of Signal right(t)','Energy of Signal left','Energy of Signal right','Power of Signal left','Power of Signal right','Form Factor of Signal left','Form Factor of Signal right','STD of Signal left(t)','STD of Signal right(t)','Skewness of Signal left','Skewness of Signal right','Kurtosis of Signal left','Kurtosis of Signal right', ...
    'Ratio of Energy to previous window left','Ratio of Energy to previous window right','Ratio of Energy to next window left','Ratio of Energy to next window right','Ratio of Energy to all epochs left','Ratio of Energy to all epochs right','Ratio of Energy to all Signals left','Ratio of Energy to all Signals right','Ratio of Form Factor to all epochs left', 'Ratio of Form Factor to all epochs right',...
    'Ratio of Form Factor to all Signals left','Ratio of Form Factor to all Signals right','Ratio of STD to all epochs left','Ratio of STD to all epochs right','Ratio of STD to all Signals left','Ratio of STD to all Signals right','Sleep stage transitions','Distribution of sleep stages, W','Distribution of sleep stages, REM','Distribution of sleep stages, N1','Distribution of sleep stages, N2','Distribution of sleep stages, N3','Average length of sleep stages, W','Average length of sleep stages, REM','Average length of sleep stages, N1','Average length of sleep stages, N2','Average length of sleep stages, N3', ...
    'Correlation coefficient','Energy of Signal 0-2Hz left','Energy of Signal 0-2Hz right','Energy of Signal 2-4Hz left','Energy of Signal 2-4Hz right','Relative energy to all epochs 0-2Hz left','Relative energy to all epochs 0-2Hz right','Relative energy to all Signals 0-2Hz left','Relative energy to all Signals 0-2Hz right','Relative energy to all epochs 2-4Hz left','Relative energy to all epochs 2-4Hz right','Relative energy to all Signals 2-4-Hz left','Relative energy to all Signals 2-4-Hz right', ...
    'Mean of Signal (f)','STD of Signal (f)','Presence of EMs','Presence of REMs','Presence of SEMs','Amount of EMs','Amount of REMs','Amount of SEMs'});
ResponsevarTraining = 0;
for i = 1:69
    OutTrainingSub = OutAll{1,i};
    OutTraining = [OutTraining; OutTrainingSub];
    ResponsevarTrainingSub = ResponsevarAll{1,i};
    ResponsevarTraining = [ResponsevarTraining ResponsevarTrainingSub];
end
OutTraining = OutTraining(2:end,:);
ResponsevarTraining = ResponsevarTraining(2:end);
% Change letters to numbers
[OutTraining, ResponsevarTraining] = LetterConversion(OutTraining,ResponsevarTraining);
% Put all test data together, 30% of the data will be used for testing
OutTest = array2table(zeros(1,size(OutAll{1,4},2)),'VariableNames',{'Diagnosis','Sleep Stages','Mean of Signal left(t)','Mean of Signal right(t)','Energy of Signal left','Energy of Signal right','Power of Signal left','Power of Signal right','Form Factor of Signal left','Form Factor of Signal right','STD of Signal left(t)','STD of Signal right(t)','Skewness of Signal left','Skewness of Signal right','Kurtosis of Signal left','Kurtosis of Signal right', ...
    'Ratio of Energy to previous window left','Ratio of Energy to previous window right','Ratio of Energy to next window left','Ratio of Energy to next window right','Ratio of Energy to all epochs left','Ratio of Energy to all epochs right','Ratio of Energy to all Signals left','Ratio of Energy to all Signals right','Ratio of Form Factor to all epochs left', 'Ratio of Form Factor to all epochs right',...
    'Ratio of Form Factor to all Signals left','Ratio of Form Factor to all Signals right','Ratio of STD to all epochs left','Ratio of STD to all epochs right','Ratio of STD to all Signals left','Ratio of STD to all Signals right','Sleep stage transitions','Distribution of sleep stages, W','Distribution of sleep stages, REM','Distribution of sleep stages, N1','Distribution of sleep stages, N2','Distribution of sleep stages, N3','Average length of sleep stages, W','Average length of sleep stages, REM','Average length of sleep stages, N1','Average length of sleep stages, N2','Average length of sleep stages, N3', ...
    'Correlation coefficient','Energy of Signal 0-2Hz left','Energy of Signal 0-2Hz right','Energy of Signal 2-4Hz left','Energy of Signal 2-4Hz right','Relative energy to all epochs 0-2Hz left','Relative energy to all epochs 0-2Hz right','Relative energy to all Signals 0-2Hz left','Relative energy to all Signals 0-2Hz right','Relative energy to all epochs 2-4Hz left','Relative energy to all epochs 2-4Hz right','Relative energy to all Signals 2-4-Hz left','Relative energy to all Signals 2-4-Hz right', ...
    'Mean of Signal (f)','STD of Signal (f)','Presence of EMs','Presence of REMs','Presence of SEMs','Amount of EMs','Amount of REMs','Amount of SEMs'});
ResponsevarTest = 0;
for i = 70:99
    OutTestSub = OutAll{1,i};
    OutTest = [OutTest; OutTestSub];
    ResponsevarTestSub = ResponsevarAll{1,i};
    ResponsevarTest = [ResponsevarTest ResponsevarTestSub];
end
OutTest = OutTest(2:end,:);
ResponsevarTest = ResponsevarTest(2:end);
% Change letters to numbers
[OutTest, ResponsevarTest] = LetterConversion(OutTest,ResponsevarTest);
%% Feature selection
[MainFeatures1,idx1] = FeatureSelection(OutTraining,ResponsevarTraining,1,1); fprintf('Feature Selection 1 is DONE...')
[MainFeatures2,idx2] = FeatureSelection(OutTraining,ResponsevarTraining,2,1); fprintf('Feature Selection 2 is DONE...')
%% Classifier
[Classifier1,~] = Classifier(OutTraining, MainFeatures1, 1); fprintf('Classifier 1 is DONE...')
[Classifier2,~] = Classifier(OutTraining, MainFeatures2, 1); fprintf('Classifier 2 is DONE...')
[Classifier3,idx3] = Classifier(OutTraining, [], 0); fprintf('Classifier 3 is DONE...')
%% Change testdata according to feature selection
OutTest1 = OutTest(:,idx1);
OutTest2 = OutTest(:,idx2);
OutTest3 = OutTest(:,idx3);
%% Classification (Classifier,OutTest, ResponseVarTest)
Classification1 = Classification(Classifier1,OutTest1, ResponsevarTest); fprintf('Classification 1 is DONE...')
Classification2 = Classification(Classifier2,OutTest2,ResponsevarTest); fprintf('Classification 2 is DONE...')
Classification3 = Classification(Classifier3, OutTest3, ResponsevarTest); fprintf('Classification 3 is DONE...')
%% Plot confusion matrices
% First, extract the results from the cells
for i = 1:length(Classification1)
    Classification1Sub = Classification1{i,1};
    if Classification1Sub == '1'
        Classification1Final(i) = 1;
    elseif Classification1Sub == '2'
        Classification1Final(i) = 2;
    elseif Classification1Sub == '3'
        Classification1Final(i) = 3;
    else
        Classification1Final(i) = 4;
    end

    Classification2Sub = Classification2{i,1};
    if Classification2Sub == '1'
        Classification2Final(i) = 1;
    elseif Classification2Sub == '2'
        Classification2Final(i) = 2;
    elseif Classification2Sub == '3'
        Classification2Final(i) = 3;
    else
        Classification2Final(i) = 4;
    end

    Classification3Sub = Classification3{i,1};
    if Classification3Sub == '1'
        Classification3Final(i) = 1;
    elseif Classification3Sub == '2'
        Classification3Final(i) = 2;
    elseif Classification3Sub == '3'
        Classification3Final(i) = 3;
    else
        Classification3Final(i) = 4;
    end
end
% Create confusion matrices
C1 = confusionmat(ResponsevarTest,Classification1Final);
C2 = confusionmat(ResponsevarTest,Classification2Final);
C3 = confusionmat(ResponsevarTest,Classification3Final);

figure; confusionchart(C1)
figure; confusionchart(C2)
figure; confusionchart(C3)

%% Determine classification of patients themselves
P1 = [4, 4, 4, 1, 1, 4, 3, 4, 1, 1, 1, 2, 2, 4, 1, 4, 4, 4, 1, 1, 1, 4, 1, 4, 4];
P2 = [4, 4, 4, 1, 1, 4, 3, 4, 1, 1, 1, 2, 2, 4, 1, 4, 4, 4, 1, 1, 1, 4, 1, 4, 4];
P3 = [4, 4, 4, 1, 1, 4, 3, 4, 1, 1, 1, 4, 2, 4, 1, 4, 4, 4, 1, 1, 1, 4, 1, 4, 4];
REF = [4, 4, 4, 1, 1, 4, 3, 4, 1, 1, 1, 2, 2, 4, 1, 4, 4, 4, 1, 1, 1, 4, 1, 4, 4];

CP1 = confusionmat(REF,P1);
CP2 = confusionmat(REF,P2);
CP3 = confusionmat(REF,P3);

figure; confusionchart(CP1)
figure; confusionchart(CP2)
figure; confusionchart(CP3)