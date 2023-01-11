% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

close all; clear all; clc

%% Load files
j = 3;
% First make the Folder Directory
MyFolder = '*Filepath to Dataset*';
% Now find all files in the folder and subfolders that have to be included
filePattern = fullfile(MyFolder,'**/*.*');
TheFiles = dir(filePattern);
% Delete subfolders themselves
TheFiles = TheFiles(222:end);
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
    DiagFile = extractAfter(FullFileName,'*Folder with Dataset*');
    DiagnosisNames = table2cell(DiagnosisFile(:,1));
    Diagloc = find(strcmp(DiagFile,DiagnosisNames));
    DiagNumbers = DiagnosisFile(Diagloc,2:3);
    % Load data
    [header, data, hypnogram, loo] = dcsm_data_read(FullFileName, 0, {'CHIN'});
    % Extract specific data needed
    chinloc = find(contains(cellstr(header.channels), 'CHIN'));
    chin = data{chinloc,:}';
    LightsOff = loo.Lights_off;
    LightsOn = loo.Lights_on;
    if LightsOff == 0 || LightsOn == 0 || isempty(chinloc)
        continue
    end
    fs = header.hdr.numbersperrecord(1);
    disp(j)
    %% Preprocessing step 1: High-pass filter to delete offset
    [b1,a1] = butter(2,10/fs,'high');
    chinfilt = filtfilt(b1,a1,chin);
    %% Preprocessing step 2: Low-pass filter to have only relevant frequencies remain
    [b2,a2] = butter(2,100/fs,'low');
    chinfilt = filtfilt(b2,a2,chinfilt);
    %% Preprocessing step 3: Notch filter to delete electricity net influence
    [b3, a3] = butter(2,[48/fs 52/fs],'stop');
    chinfilt = filtfilt(b3,a3,chinfilt);
    %% Cut data from LightsOff to LightsOn (only relevant data is necessary)
    ToCutBeginExcess = mod(LightsOff,(30));
    ToCutEndExcess = mod(LightsOn,(30));
    Begin = LightsOff - ToCutBeginExcess;
    End = LightsOn + ((30)-ToCutEndExcess);
    if End > (length(chin)/fs)
        continue
    end
    if (End/30) > length(hypnogram) 
        continue
    end
    chinfilt = chinfilt((Begin*fs)+1:(End*fs));
    chin = chin((Begin*fs)+1:(End*fs));
    hypnogram = hypnogram((Begin/30)+1:(End/30));
    %% Feature extraction
    [Features, Response] = FeaturesComparison(hypnogram, LightsOff, LightsOn,fs, chinfilt,DiagNumbers);

    FeaturesAll{j} = Features;
    ResponseAll{j} = Response;

    fprintf('Feature Extraction is DONE...')
end
save('FeaturesComparisonAll.mat','FeaturesAll')
save('ResponseComparisonAll.mat','ResponseAll')
%% Divide data into training and test data
a = 0;
OutTest = array2table(zeros(1,size(Features,2)),'VariableNames',{'Diagnosis','Hypnogram','Sleep Onset Latency','Wake After Sleep Onset','Total Sleep Time','Time in Bed','Sleep Efficiency','Arousal Index','Minutes of REM Sleep',...
    'Proportion of N1 Sleep','Proportion of N2 Sleep','Proportion of N3 Sleep','Proportion of REM Sleep','NREM Fragmentation Index','REM Fragmentation Index','Wake Proportion',...
    'Sleep Transition Index','Average Length N1','Average Length N2','Average Length N3','Average Length REM','REM Sleep Atonia Index','Mean Frequency of REM mini-epochs',...
    'Median Frequency of REM mini-epochs','Spectral Edge Frequency at 95% of REM mini-epochs'});
ResponseTest = 0;
for i = 2:length(FeaturesAll)
    OutTestSub = FeaturesAll{1,i};
    OutTest = [OutTest; OutTestSub];
    ResponseTestSub = ResponseAll{1,i};
    ResponseTest = [ResponseTest ResponseTestSub];
end
OutTest = OutTest(2:end,:);
ResponseTest = ResponseTest(2:end);
%% Classifier
ImportantFeatures = FeatureSelection(OutTest,ResponseTest,1,1);
ClassifierFinal = ClassifierComparison(ImportantFeatures, ResponseTest); fprintf('Classifier is DONE...')
%% Classification
ClassificationFinal = Classification(); fprintf('Classification is DONE...')
%% Plot confusion matrices
C4 = confusionmat(ResponseTest,ClassificationFinal);
figure; confusionchart(C4)

%% Determine classification of patients themselves
P = [1,1,1,1,1,4,4,1,1,1,2,1,4,3,1,3,1,2,4,1,2,1,1,4,1,1,1,1,1];
REF = [4,4,4,1,1,4,3,4,1,1,1,2,2,4,1,4,3,4,1,1,1,4,1,4,4,2,2,1,2];

CP = confusionmat(REF,P);
figure; confusionchart(CP)