%% Channel statistics
clear all; close all;

%% Set up variables
f_path = 'G:\GlostrupRBD';
folders = dir([f_path '\DCSM*']);
channels = cell(size(folders));
cfg = struct('read_data',false);

%% Find data with wrong copied folder structure and missing data

for i = 1:size(folders,1)
    d_path = [folders(i).folder '\' folders(i).name];
    d_path_content = dir(d_path);
    if sum(contains({d_path_content.name},{'contiguous.edf','hypnogram.csv','lights.txt'})) ~= 3
        disp(d_path);
    end
end
    
%% Iterate data

for i = 1:size(folders,1)
    d_path = [folders(i).folder '\' folders(i).name];
    edf_path = [char(d_path) '\contiguous.edf'];
    if ~exist(edf_path,'file')
        continue;
    end
    [~, header] = lab_read_edf(edf_path,cfg,false);
    if isstruct(header)
        channels{i} = {header.channels, header.hdr.numbersperrecord};
    end
    if mod(i,10) == 0 || i == 1 || i == size(folders,1)
        fprintf('File %d/%d. \n',i,size(folders,1));
    end
end

save('Channels','channels');

%% Summarize channel overivew
%  Names, numbesr, and sampling frequencies
channel_stats = cell(1,8);
for i = 1:size(channels,1)
    if ~isempty(channels{i})
        for j = 1:size(channels{i}{1},1)
            label = deblank(channels{i}{1}(j,:));
            fs = channels{i}{2}(j);
            if i == 1 && j == 1
                channel_stats{1,1} = label;
                channel_stats{1,2} = 1;
                channel_stats{1,3} = fs;
            end
            match = find(strcmp(channel_stats(:,1), label));
            if isempty(match)
                new_idx = 1 + size(channel_stats,1);
                channel_stats{new_idx,1} = label;
                channel_stats{new_idx,2} = 1;
                channel_stats{new_idx,3} = fs;
            else
                channel_stats{match,2} = channel_stats{match,2} + 1;
                channel_stats{match,3} = [channel_stats{match,3} fs];
            end
        end
    end
end
for i = 1:size(channel_stats,1)
    channel_stats{i,4} = unique(channel_stats{i,3});
    channel_stats{i,5} = min(channel_stats{i,3});
    channel_stats{i,6} = max(channel_stats{i,3});
    channel_stats{i,7} = mean(channel_stats{i,3});
    channel_stats{i,8} = median(channel_stats{i,3});
end

save('Channel_Stats','channel_stats');

%% Test channel dict
[channel_alias, channel_alias_ref1, channel_alias_ref2] = get_channel_alias();
export_chan = {'C3','C4','F3','F4','O1','O2','EOGR','EOGL','TIBR','TIBL','ECG','CHIN','NASALPRES','ABD','THO','SaO2'};
has_chan = zeros(size(channels,1), size(export_chan,2));
for i = 1:size(channels,1)
    if ~isempty(channels{i})
        for j = 1:size(export_chan,2)
            has_ref1 = 0;
            has_ref2 = 0;
            for c = 1:size(channels{i}{1},1)
                label = deblank(channels{i}{1}(c,:));
                if any(strcmp(channel_alias.(export_chan{j}),label))
                    has_chan(i,j) = 1;
                    continue;
                end
                if ~isempty(channel_alias_ref1.(export_chan{j}))
                    if any(strcmp(channel_alias_ref1.(export_chan{j}),label))
                        has_ref1 = 1;
                    end
                    if any(strcmp(channel_alias_ref2.(export_chan{j}),label))
                        has_ref2 = 1;
                    end
                end
                if has_ref1 == 1 && has_ref2 == 1
                    has_chan(i,j) = 1;
                    continue;
                end
            end
        end
    end
end



