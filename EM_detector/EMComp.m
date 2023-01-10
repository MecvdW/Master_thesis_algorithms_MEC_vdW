% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

function [EventDetectionBehavior, EMManSEMs, EMManREMs,EMManEMs,EMDetSEMs,EMDetREMs,EMDetEMs] = EMComp(scoringStart, quantification, Events, dataLAll, j, EM, REMs, SEMs,hypnogramplt)
if quantification == 1
    % Load files either from Fabio or from Helle
    % Make File Directory
    if Events == 1
        MyFolderEvents = 'C:\Users\marle\Documents\Data_master_thesis\Events_Fabio';
    elseif Events == 2
        MyFolderEvents = 'C:\Users\marle\Documents\Data_master_thesis\Events_Helle';
    end
    % Now find all files in the folder and subfolders that have to be included
    filePatternEvents = fullfile(MyFolderEvents, '*.txt');
    TheFilesEvents = dir(filePatternEvents);
    % Import the files
    baseFileNameEvents = TheFilesEvents(j).name;
    FullFileNameEvents = fullfile(TheFilesEvents(j).folder, baseFileNameEvents);
    EventData = importdata(FullFileNameEvents);
    % Find all data points that are logged with an EM, WEM, SEM, or REM
    isEM = cellfun(@(x)isequal(x,'EM'),EventData.textdata);
    [EventDataEM, ~] = find(isEM);
    isWEM = cellfun(@(x)isequal(x,'WEM'),EventData.textdata);
    [EventDataWEM, ~] = find(isWEM);
    isSEM = cellfun(@(x)isequal(x,'SEM'),EventData.textdata);
    [EventDataSEM, ~] = find(isSEM);
    isREM = cellfun(@(x)isequal(x,'REM'),EventData.textdata);
    [EventDataREM, ~] = find(isREM);
    isREMSEM = cellfun(@(x)isequal(x,'REM+SEM'),EventData.textdata);
    [EventDataREMSEM, ~] = find(isREMSEM);
    isNREMREM = cellfun(@(x)isequal(x,'NREMREM'),EventData.textdata);
    [EventDataNREMREM, ~] = find(isNREMREM);
    % Find correct length of all Events
    EventDataLength = [EventData.data(:,1) EventData.data(:,1)+EventData.data(:,2)];
    % Cut Wake from files
    EventDataLength = EventDataLength - scoringStart;
    % Construct separate matrices
    EventDataEM = EventDataLength(EventDataEM,:);
    EventDataWEM = EventDataLength(EventDataWEM,:);
    EventDataSEM = EventDataLength(EventDataSEM,:);
    EventDataREM = EventDataLength(EventDataREM,:);
    EventDataREMSEM = EventDataLength(EventDataREMSEM,:);
    EventDataNREMREM = EventDataLength(EventDataNREMREM,:);
    % For every data point determine whether there is a correspondence
    EMDetEMs = zeros(length(dataLAll),1); EMDetREMs = zeros(length(dataLAll),1); EMDetSEMs = zeros(length(dataLAll),1);
    EMManEMs = zeros(length(dataLAll),1); EMManREMs = zeros(length(dataLAll),1); EMManSEMs = zeros(length(dataLAll),1);

    EMDetEMs = EMMat(EM,EMDetEMs);
    EMDetREMs = EMMat(REMs,EMDetREMs);
    EMDetSEMs = EMMat(SEMs,EMDetSEMs);
    EMManREMs = EMMat(EventDataREM,EMManREMs);
    EMManSEMs = EMMat(EventDataSEM,EMManSEMs);
    EMManEMs = EMMat(EventDataEM,EMManEMs);
    EMManEMs = EMMat(EventDataNREMREM,EMManEMs);
    EMManEMs = EMMat(EventDataREMSEM,EMManEMs);
    EMManEMs = EMMat(EventDataWEM,EMManEMs);
    EMManEMs = EMMat(EventDataREM,EMManEMs);
    EMManEMs = EMMat(EventDataSEM,EMManEMs);

    % (TP,TN,FP,FN)
    [EMAccu, EMSens, EMSpec, EMTP, EMTN, EMFP, EMFN,EventStageEM] = EMAcc(EMManEMs,EMDetEMs,hypnogramplt, 1);
    [REMAccu, REMSens, REMSpec, REMTP, REMTN, REMFP, REMFN,EventStageREM] = EMAcc(EMManREMs, EMDetREMs,hypnogramplt, 1);
    [SEMAccu, SEMSens, SEMSpec, SEMTP, SEMTN, SEMFP, SEMFN,EventStageSEM] = EMAcc(EMManSEMs, EMDetSEMs,hypnogramplt, 1);
    % Combine results
    EventDetectionBehavior = [EMTP EMTN EMFP EMFN; REMTP REMTN REMFP REMFN; SEMTP SEMTN SEMFP SEMFN];
else
    EventDetectionBehavior = [];
end
end