% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

function [EM, REMs, SEMs, EMAm, REMAm, SEMAm, EventDetectionBehavior, EMManSEMs, EMManREMs,EMManEMs,EMDetSEMs,EMDetREMs,EMDetEMs] = EMdetector(EventDataEMscoring, hypnogram, dataLAll, dataRAll, dataLFilt, dataRFilt, fs, figs, quantification, j, Events)
%% Results of the EM detector
[EM, SGR, SGL, diffEOG, thresExcand, SEMs, REMs] = EMdet(dataRFilt, dataLFilt, fs);

%% Split up EM detector results to plot 30s epochs
%Fix length of hypnogram
hypnogramplt = repelem(hypnogram(1:end),30*fs);
if length(hypnogramplt) > length(dataLAll)
    lengthHypnogram = length(dataLAll)/(30*fs);
    hypnogram = hypnogram(1:lengthHypnogram); hypnogramplt = repelem(hypnogram,30*fs);
end
eoglm230s = reshape(dataLAll, [30*fs, (length(hypnogram))]); eogrm230s = reshape(dataRAll, [30*fs, (length(hypnogram))]);
eoglm2filt30s = reshape(dataLFilt, [30*fs, (length(hypnogram))]); eogrm2filt30s = reshape(dataRFilt, [30*fs, (length(hypnogram))]);
SGL30s = reshape(SGL, [30*fs, (length(hypnogram))]); SGR30s = reshape(SGR, [30*fs, (length(hypnogram))]);
diffEOG30s = reshape(diffEOG, [30*fs, (length(hypnogram))]);

%% Calculate correspondence between manually found EMs and and automatically found EMs
if quantification == 1
    [EventDetectionBehavior, EMManSEMs, EMManREMs,EMManEMs,EMDetSEMs,EMDetREMs,EMDetEMs] = EMComp(EventDataEMscoring, quantification, Events, dataLAll, j, EM, REMs, SEMs,hypnogramplt);
else
    [EventDetectionBehavior] = 0;
end
%% Find amount of EMs, REMs, and SEMs per 30s epoch
EMAm = 0;
REMAm = 0;
SEMAm = 0;
EMevents = zeros(size(hypnogram,1),2);
REMevents = zeros(size(hypnogram,1),2);
SEMevents = zeros(size(hypnogram,1),2);
for i = 1:size(eoglm2filt30s,2)
    EMevent = 0;
    REMevent = 0;
    SEMevent = 0;
    if i > 1
        if EMevents(end,2) == (fs*30*(i-1))
            EMevent = 1;
        end
        if REMevents(end,2) == (fs*30*(i-1))
            REMevent = 1;
        end
        if SEMevents(end,2) == (fs*30*(i-1))
            SEMevent = 1;
        end
    end
    % Find events in every epoch apart
    EMevents = EpochEvents(EM, EMevent, fs, i);
    REMevents = EpochEvents(REMs, REMevent, fs, i);
    SEMevents = EpochEvents(SEMs, SEMevent, fs, i);
    % Find amounts of events in every epoch
    EMAm = [EMAm; size(EMevents,1)];
    REMAm = [REMAm; size(REMevents,1)];
    SEMAm = [SEMAm; size(SEMevents,1)];
end
EMAm(all(EMAm == 0,2),:) = [];
REMAm(all(REMAm == 0,2),:) = [];
SEMAm(all(SEMAm == 0,2),:) = [];

ep = 257;
% Find positions of EM candidates
thresExcand30s = EpochEvents(thresExcand, 0, fs, ep);
EM30s = EpochEvents(EM, 0, fs, ep);
REM30s = EpochEvents(REMs, 0, fs, ep);
SEM30s = EpochEvents(SEMs, 0, fs, ep);
thresSub = ones(size(thresExcand30s)) * ((ep*30*fs)+1)-(30*fs); EMSub = ones(size(EM30s)) * ((ep*30*fs)+1)-(30*fs); REMSub = ones(size(REM30s)) * ((ep*30*fs)+1)-(30*fs); SEMSub = ones(size(SEM30s)) * ((ep*30*fs)+1)-(30*fs);
% Create final matrices with EM candidates and events
thresExcand30s = thresExcand30s - thresSub; EM30s = EM30s - EMSub; REM30s = REM30s - REMSub; SEM30s = SEM30s - SEMSub;
%% Global variables
t = (1/fs):(1/fs):(length(eoglm230s(:,ep))/fs);

%% Plot EM events per 30s epoch
if figs == 1
    fig = figure; subplt2 = subplot(5,1,1); plot(t,eoglm2filt30s(:,ep),'Parent',subplt2); hold on; plot(t,eogrm2filt30s(:,ep),'Parent',subplt2);legend('Left EM detector input signal','Right EM detector input signal','Location','northwest');ylim(subplt2,[-200 200]);xlim(subplt2,[0 length(eoglm2filt30s)/fs]);
    subplt3 = subplot(5,1,2); plot(t,SGL30s(:,ep),'Parent',subplt3); hold on; plot(t,SGR30s(:,ep),'Parent',subplt3);legend('Left SG filtered signal','Right SG filtered signal','Location','northwest');ylim(subplt3,[-200 200]);xlim(subplt3,[0 length(eoglm2filt30s)/fs])
    subplt4 = subplot(5,1,3); plot(t,diffEOG30s(:,ep),'Parent',subplt4,'Color','k');legend('Subtracted signal (EOGL - EOGR','Location','northwest');ylim(subplt4,[-200 200]);xlim(subplt4,[0 length(eoglm2filt30s)/fs]);
    subplt5 = subplot(5,1,4); plot(t,diffEOG30s(:,ep),'Parent',subplt5,'Color','k');hold on; thresTime = [thresExcand30s(:,1) thresExcand30s(:,2)]; sortArrayCand = [ones(length(thresExcand30s),1) zeros(length(thresExcand30s),1)];
    [bCand, ICand] = sort(thresTime); sortTimeCand = sortArrayCand(ICand); bCandSub = ones(size(bCand)) * fs; bCand = bCand./bCandSub;
    stairs(bCand',sortTimeCand','m','LineWidth',2,'Parent',subplt5);legend('Subtracted signal (EOGL - EOGR)','EM_c_a_n_d_i_d_a_t_e_s','Location','northwest');xlim(subplt5,[0 length(eoglm2filt30s)/fs]);ylim(subplt5,[-200 200]);
    subplt6 = subplot(5,1,5); plot(t,diffEOG30s(:,ep),'Parent',subplt6,'Color','k');hold on;EMTime = [EM30s(:,1) EM30s(:,2)]; sortArrayEM = [ones(length(EM30s),1) zeros(length(EM30s),1)];
    [bEM, IEM] = sort(EMTime); sortTimeEM = sortArrayEM(IEM); bEMSub = ones(size(bEM)) * fs; bEM = bEM./bEMSub;
    stairs(bEM',sortTimeEM','m','LineWidth',2,'Parent',subplt6);hold on;REMTime = [REM30s(:,1) REM30s(:,2)]; sortArrayREM = [ones(length(REM30s),1) zeros(length(REM30s),1)];
    [bREM, IREM] = sort(REMTime); sortTimeREM = sortArrayREM(IREM)*50; bREMSub = ones(size(bREM)) * fs; bREM = bREM./bREMSub;
    stairs(bREM',sortTimeREM','r','LineWidth',2,'Parent',subplt6);hold on;SEMTime = [SEM30s(:,1) SEM30s(:,2)]; sortArraySEM = [ones(length(SEM30s),1) zeros(length(SEM30s),1)];
    [bSEM, ISEM] = sort(SEMTime); sortTimeSEM = sortArraySEM(ISEM)*-50; bSEMSub = ones(size(bSEM)) * fs; bSEM = bSEM./bSEMSub;
    stairs(bSEM',sortTimeSEM','c','LineWidth',2,'Parent',subplt6);legend('Subtracted signal (EOGL - EOGR)','Detected EMs','Detected REMs','Detected SEMs','Location','northwest');xlim(subplt6,[0 length(eoglm2filt30s)/fs]);ylim(subplt6,[-200 200]);

    % Title and axes
    handle = axes(fig,'Visible','off'); handle.Title.Visible='on';handle.XLabel.Visible='on';handle.YLabel.Visible='on';
    xticklabels = 0:(length(eoglm230s(:,ep))/fs); xticks(subplt6,xticklabels);set(subplt6,'XTickLabel',{0:(length(eoglm230s(:,ep))/fs)})
    set(subplt5,'XTickLabel',{[]}); set(subplt4,'XTickLabel',{[]}); set(subplt3,'XTickLabel',{[]}); set(subplt2,'XTickLabel',{[]})
    xlabel(handle,'Time (s)'); ylabel(handle,'Current (mV)'); title(handle,'Results of automatic EM detector compared to manually scored eye movement events');
end
end