% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

function [thresEx, SGfiltR, SGfiltL, diffEOG, thresExcand, SlowEMs, RapidEMs] = EMdet(dataR, dataL, fs)
% The full EM detector consists of a smoothing procedure,subtracting of
% EOGL and EOGR, thresholding combining and eliminating. The cleaning
% procedure is done using a Savitzky-Golay smoothing
% filter.

%% Construct Savitzky-Golay smoothing filter
% First the values for window length and order are chosen randomly, will possibly be
% changed when the filter is working and can be tested
wl = 17;
ord = 5;
SGfiltR = sgolayfilt(dataR,ord,wl);
SGfiltL = sgolayfilt(dataL,ord,wl);

%% Subtracting EOGL from EOGR
diffEOG = SGfiltR  - SGfiltL;

%% Apply thresholding to eliminate events unrelated to EMs
diffEOG(diffEOG>600) = 0;
diffEOG(diffEOG<-600) = 0;

% From here, the original EOG difference can be added to compare the
% results of both EM detectors. This will be added later

%% Compute the Pth percentile, distinguishing EMs from non EMs
% Using the Pth percentile, candidate EM vectors can be constructed
Pth = 91;
Perc = prctile(diffEOG,Pth);

% Find first threshold pass
indxpass = abs(diffEOG) >= Perc;

% Find array where threshold is exceeded
a = 0; b = 0;
indx = find(indxpass);
if indx(1) == 1
    indx(1) = [];
    a = 1;
end

if indx(end) == size(diffEOG,1)
    indx(end) = [];
    b = 1;
end
passUp = abs(diffEOG(indx-1))<Perc;
indxUp = indx(passUp);

passDown = abs(diffEOG(indx+1))<Perc;
indxDown = indx(passDown);

if a == 1 && length(indxDown) > length(indxUp) || a== 1 && length(indxDown) < length(indxUp)
    indxDown(1) = [];
end

if b == 1 && length(indxDown) > length(indxUp) || b == 1 && length(indxDown) < length(indxUp)
    indxUp(end) = [];
end
% Create actual array
thresExcand = cat(2,indxUp,indxDown);

%% Determine minimum distance between EMs and minimum length of EMs
EMdis = 153;%0.6*fs;
EMleng = 76;%0.3*fs;

% Remove gaps when the minimum distance between EMs is not reached
k = 1;
thresEx = thresExcand;
while k <= size(thresEx,1)-1 && size(thresEx,1) > 1
    if thresEx(k+1,1)-thresEx(k,2) <= EMdis
        thresEx(k,2) = thresEx(k+1,2);
        thresEx(k+1,:) = [];
    else
        k = k+1;
    end
end

% Remove EM candidates where minimum length of EMs is not reached
k2 = 1;
while k2 <= size(thresEx,1)-1 && size(thresEx,1) > 1
    if (thresEx(k2,2)-thresEx(k2,1))<= EMleng
        thresEx(k2,:) = [];
    else
        k2 = k2+1;
    end
end

% Find whether there is correlation or anti-correlation during EMs
k3 = 1;
while k3 <= size(thresEx,1)
    period = thresEx(k3,1):thresEx(k3,2);
    SignalL = SGfiltL(period);
    SignalR = SGfiltR(period);
    % Find correlation between signals during the period
    Corrcoef = corrcoef(SignalL,SignalR);
    if Corrcoef(1,2) > 0.35
        thresEx(k3,:) = [];
    else
        k3 = k3+1;
    end
end

% Find EM candidates that are too long
k4 = 1;
while k4 <= size(thresEx,1)
    period = thresEx(k4,1):thresEx(k4,2);
    if isempty(period)
        k4 = k4+1;
        continue
    elseif period(end) - period(1) >= 6000
        thresEx(k4,:) = [];
    else
        k4 = k4+1;
    end
end
% Calculate the total amount of EM (candidates) in the vector
totalEM = sum(thresEx(:,2)-thresEx(:,1));

%% Distinguish Slow EMs and Rapid EMs
SlowEMs = zeros(1,2);
RapidEMs = zeros(1,2);
for i = 1:size(thresEx,1)
    % Determine period of Eye movement
    period = thresEx(i,1):thresEx(i,2);
    % Period has to have a minimal length of 0.3 seconds which corresponds
    % to 256/3 = 76 datapoints
    if thresEx(i,1) == thresEx(i,2)
        continue
    elseif isempty(period)
        continue
    elseif period(end) - period(1) <= 76 %0.3 seconds should be short enough for both kinds
        continue
    end
    % Find eye movement periods that are longer than 2x0.3 seconds
    if period(end) - period(1) >= 152
        periodFinal = zeros(1,76);
        for j = 1:19:period(end)
            if period(end) - period(j) <= 76
                periodFinal = [periodFinal; period(end-75):period(end)];
                break
            else
                periodFinal = [periodFinal; period(j):period(j+75)];
            end
        end
    else
        periodFinal = period;
    end
    % Delete rows with only zeros
    periodFinal(all(periodFinal == 0,2),:) = [];
    % Find data corresponding with the found period
    data = zeros(76,1);
    if size(periodFinal,1) == 1
        data = diffEOG(periodFinal);
    else
        for k = 1:size(periodFinal,1)
            data = [data diffEOG(periodFinal(k,:))];
        end
    end
    data(all(data == 0,2),:) = [];

    for k = 1:size(periodFinal,1)
        % Calculate the frequency content
        Freqs = fft(data(:,k));
        % Calculate the energy under 1Hz and over 1Hz
        FreqEn01 = Energy(Freqs,[0 1],fs);
        FreqEn15 = Energy(Freqs,[1 5],fs);
        % Determine which periods are Slow EMs and which are Rapid EMs by
        % finding the interval with the highest energy
        if sum(FreqEn01) >= sum(FreqEn15)
            SlowEMs = [SlowEMs; [periodFinal(k,1) periodFinal(k,end)]];
            RapidEMs = [RapidEMs; 0 0];
        elseif sum(FreqEn01) <= sum(FreqEn15) && length(periodFinal) <= 128
            RapidEMs = [RapidEMs; [periodFinal(k,1) periodFinal(k,end)]];
            SlowEMs = [SlowEMs; 0 0];
        end
    end

end
SlowEMs(all(SlowEMs == 0,2),:) = [];
RapidEMs(all(RapidEMs == 0,2),:) = [];
end