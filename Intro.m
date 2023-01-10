%close all
clear all
clc

%% Import files from folder
addpath 'C:\Users\marle\OneDrive\Studie\Masterthesis\Initial_data\haaglanden-medisch-centrum-sleep-staging-database-1.1\haaglanden-medisch-centrum-sleep-staging-database-1.1\recordings'
folder = dir('C:\Users\marle\OneDrive\Studie\Masterthesis\Initial_data\haaglanden-medisch-centrum-sleep-staging-database-1.1\haaglanden-medisch-centrum-sleep-staging-database-1.1\recordings');

%% EDF files
for i = 15%3:3:length(folder) %Specific choice of file
    filename = folder(i).name;

    %% Open data with specified filename
    data = edfread(filename);
    filename = filename(1:end-4);

    %% Variables
    fs = 256;
    RecTime = size(data,1) * fs -1;
    t = (0: 1/fs:(RecTime/fs))/60/60;

    %% Construct 30s epochs
    dataAllCell = cellfun(@transpose,data{:,6},'UniformOutput',false);
    dataAll = [dataAllCell{:}];
    data30 = reshape(dataAll(1:30*256*959), [30*256, 959]);

    %% Find frequency content of 30s epochs
    [Pxx, f] = Freq(data30, fs);

    %% Load sleep staging file
    filenameStage = folder(i+2).name;
    dataStage = readcell(filenameStage);

    %% Find sleep stage annotation
    for m = 1:size(dataStage,1)
        % Make a string from the contents of the cell
        dataStageStr = char(dataStage(m,5));
        if dataStageStr(1) == 'S'
            dataStageStr = dataStageStr(13:end);
        else
            dataStageStr = [];
        end
        dataStageColumn{m} = dataStageStr;
    end

    %% Visualize sleep data
    % fig = Figure(122*30:1/fs:(123*30)-1/fs,data30(:,122));
    %saveas(fig,filename)
end

%% Plots of frequency domains
figure;
plot(f{30},Pxx{30})
xlim([0 10])
xlabel('Frequency (Hz)')
ylabel('Power (W/Hz)')
title('Frequency content of EOG signal during Wakefulness')