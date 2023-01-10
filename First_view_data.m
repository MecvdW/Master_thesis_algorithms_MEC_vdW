close all
clear all
clc

%% Load data
Allfiles = dir('*.mat');%folder = dir(L:\LovbeskyttetMapper\Eye movements con-glo Julie\MatlabData\N00XX);

for i = 1:length(Allfiles)
    load(Allfiles(i,1).name);
end

%% Global variables
t = 1:length(eoglm2);

%% Visualize raw data
figure; subplt1 = subplot(2,1,1); hypnogramplt = repelem(hypnogram(1:end-1),30*256);
ylim(subplt1,[-4 2]); xlim(subplt1,[0 length(hypnogram*30*readme.fs_original(1))])
sgtitle('1=W, 0=REM, -1=N1, -2=N2, -3=N3, Raw Data'); plot(hypnogramplt,'Parent',subplt1);
subplt2 = subplot(2,1,2); plot(eoglm2,'Parent',subplt2)
hold on
plot(eogrm2,'Parent',subplt2);ylim(subplt2,[-1000 1000]);xlim(subplt2,[0 length(eoglm2)]);legend('Left EOG','Right EOG');

%% Preprocessing step 1: High-pass filter to delete offset
[b1,a1] = butter(2,0.3/readme.fs_original(1),'high');
eoglm2 = filtfilt(b1,a1,eoglm2); eogrm2 = filtfilt(b1,a1,eogrm2);

%% Preprocessing step 2: Low-pass filter to have only relevant frequencies remain
[b2,a2] = butter(2,35/readme.fs_original(1),'low');
eoglm2 = filtfilt(b2,a2,eoglm2); eogrm2 = filtfilt(b2,a2,eogrm2);

%% Preprocessing step 3: Notch filter to delete electricity net influence
[b3, a3] = butter(2,[48/readme.fs_original(1) 52/readme.fs_original(1)],'stop');
eoglm2 = filtfilt(b3,a3,eoglm2); eogrm2 = filtfilt(b3,a3,eogrm2);

%% Visualize preprocessed data
figure; subplt1 = subplot(2,1,1); hypnogramplt = repelem(hypnogram(1:end),30*256);
ylim(subplt1,[-4 2]); xlim(subplt1,[0 length(hypnogramplt*30*readme.fs_original(1))])
sgtitle('1=W, 0=REM, -1=N1, -2=N2, -3=N3, Pre-processed data'); plot(hypnogramplt,'Parent',subplt1);
subplt2 = subplot(2,1,2); plot(eoglm2,'Parent',subplt2)
hold on
plot(eogrm2,'Parent',subplt2);ylim(subplt2,[-1000 1000]);xlim(subplt2,[0 length(eoglm2)]);legend('Left EOG','Right EOG');



%% Results of the EM detector
[EM, SGR, SGL, diffEOG, thresExcand] = EMdet(eogrm2, eoglm2, readme.fs_original(1));

%% Plot EM detector results
figure; subplt1 = subplot(6,1,1); hypnogramplt = repelem(hypnogram(1:end),30*256);
ylim(subplt1,[-4 2]); xlim(subplt1,[0 length(eoglm2)])
sgtitle('1=W, 0=REM, -1=N1, -2=N2, -3=N3, Pre-processed data'); plot(hypnogramplt,'Parent',subplt1);
subplt2 = subplot(6,1,2); plot(eoglm2,'Parent',subplt2)
hold on
plot(eogrm2,'Parent',subplt2);ylim(subplt2,[-1000 1000]);xlim(subplt2,[0 length(eoglm2)]);legend('Left EOG','Right EOG');
subplt3 = subplot(6,1,3); plot(SGL,'Parent',subplt3)
hold on
plot(SGR,'Parent',subplt3);legend('Left SG filtered signal','Right SG filtered signal');ylim(subplt3,[-1000 1000]);xlim(subplt3,[0 length(eoglm2)])
subplt4 = subplot(6,1,4); plot(diffEOG,'Parent',subplt4);legend('Subtracted signal (EOGL - EOGR');ylim(subplt4,[-1000 1000]);xlim(subplt4,[0 length(eoglm2)]);
subplt5 = subplot(6,1,5); plot(diffEOG,'Parent',subplt5);
hold on
thresTime = [thresExcand(:,1) thresExcand(:,2)]; sortArrayCand = [ones(length(thresExcand),1) zeros(length(thresExcand),1)];
[bCand, ICand] = sort(thresTime); sortTimeCand = sortArrayCand(ICand); stairs(bCand',sortTimeCand','m','LineWidth',4,'Parent',subplt5);
xlim(subplt5,[0 length(eoglm2)]);ylim(subplt5,[-1000 1000]);legend('Subtracted signal (EOGL - EOGR)','EM_c_a_n_d_i_d_a_t_e_s')
subplt6 = subplot(6,1,6); plot(diffEOG,'Parent',subplt6);
hold on
EMTime = [EM(:,1) EM(:,2)]; sortArrayEM = [ones(length(EM),1) zeros(length(EM),1)];
[bEM, IEM] = sort(EMTime); sortTimeEM = sortArrayEM(IEM); stairs(bEM',sortTimeEM','m','LineWidth',4,'Parent',subplt6);
xlim(subplt6,[0 length(eoglm2)]);ylim(subplt6,[-1000 1000]);legend('Subtracted signal (EOGL - EOGR)','Detected EMs')

