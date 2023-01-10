function [header, data, hypnogram, loo] = dcsm_data_read(d_path, prune_lights_on, channel_names)

% Default vars
if ~exist('prune_lights_on','var')
    prune_lights_on = false;
end
if ~exist('channel_names','var')
    channel_names = [];
end


% EDF path
edf_path = [char(d_path) '\contiguous.edf'];
% Hypnogram path
hyp_path = [char(d_path) '\hypnogram.csv'];
% Lights off/on path
loo_path = [char(d_path) '\lights.txt'];

% Check files exsist
if ~exist(edf_path,'file') || ~exist(hyp_path,'file') || (~exist(loo_path,'file') && prune_lights_on)
    data = -1;
    hypnogram = -1;
    header = -1;
    warning('Missing files.');
    return
end

% Read EDF
[data,header] = lab_read_edf(edf_path,[],false);
% Read hypnogram
hypnogram = readmatrix(hyp_path);
% Read Lights off/on
loo = readtable(loo_path);

% Remove lights on
if prune_lights_on
    % Prune to full 30-second epoch
    lights_off_raw = loo.Lights_off;
    lights_off = ceil((lights_off_raw - 1) / 30) * 30;
    lights_on_raw = loo.Lights_on;
    lights_on = floor((lights_on_raw) / 30) * 30;
    % Prune hypnogram
    hypnogram = hypnogram((1 + lights_off/30):(lights_on/30));
    % Prune data
    for i = 1:size(data,1)
        fs = header.hdr.numbersperrecord(i);
        data{i} = data{i}((1 + lights_off * fs):(lights_on * fs));
    end
    % Prune header
    header.hdr.records = length(data{1}) / header.hdr.numbersperrecord(1);
end

% Select channels
if ~isempty(channel_names)
    % Get hardcoded channel alias'
    [channel_alias, channel_alias_ref1, channel_alias_ref2] = get_channel_alias();
    idx_channel_rem = true(size(data));
    % Iterate and look for channels
    for i = 1:length(channel_names)
        % Check referenced alias
        idx_channel = find(cellfun(@(x) any(strcmp(channel_alias.(channel_names{i}), x)), cellstr(header.channels)),1,'first');
        idx_channel_ref1 = find(cellfun(@(x) any(strcmp(channel_alias_ref1.(channel_names{i}), x)), cellstr(header.channels)),1,'first');
        idx_channel_ref2 = find(cellfun(@(x) any(strcmp(channel_alias_ref2.(channel_names{i}), x)), cellstr(header.channels)),1,'first');
        if ~isempty(idx_channel)
            % Referneced alias exist
            % Keep channel and rename
            idx_channel_rem(idx_channel) = false;
            header.channels(idx_channel,:) = pad(channel_names{i},16);
            header.hdr.channelname(idx_channel,:) = pad(channel_names{i},16);
        elseif ~isempty(idx_channel_ref1) && ~isempty(idx_channel_ref2)
            % Unreferenced alias exist
            % Keep channel and rename
            idx_channel_rem(idx_channel_ref1) = false;
            header.channels(idx_channel_ref1,:) = pad(channel_names{i},16);
            header.hdr.channelname(idx_channel_ref1,:) = pad(channel_names{i},16);
            if header.hdr.numbersperrecord(idx_channel_ref1) ~= header.hdr.numbersperrecord(idx_channel_ref2)
                % Resample ref2 electrode
                fs = header.hdr.numbersperrecord(idx_channel_ref2);
                des_fs = header.hdr.numbersperrecord(idx_channel_ref1);
                [p,q] = rat(des_fs/fs);
                data{idx_channel_ref2} = resample(data{idx_channel_ref2},p,q);
                header.hdr.numbersperrecord(idx_channel_ref2) = des_fs;
            end
            if ~length(data{idx_channel_ref1}) == length(data{idx_channel_ref2})
                % Zero-pad ref2 electrode
                if length(data{idx_channel_ref2}) > length(data{idx_channel_ref1})
                    data{idx_channel_ref2} = data{idx_channel_ref2}(1:length(data{idx_channel_ref1}));
                else
                    data{idx_channel_ref2} = [data{idx_channel_ref2} zeros(1,length(data{idx_channel_ref2})-length(data{idx_channel_ref1}))];
                end
            end
            data{idx_channel_ref1} = data{idx_channel_ref1} - data{idx_channel_ref2};
            
        end
    end
    % Remove unwanted channels
    data(idx_channel_rem) = [];
    header.numchannels = sum(~idx_channel_rem);
    header.channels(idx_channel_rem,:) = [];
    header.hdr.channels = sum(~idx_channel_rem);
    header.hdr.channelname(idx_channel_rem,:) = [];
    header.hdr.transducer(idx_channel_rem,:) = [];
    header.hdr.physdime(idx_channel_rem,:) = [];
    header.hdr.physmin(idx_channel_rem,:) = [];
    header.hdr.physmax(idx_channel_rem,:) = [];
    header.hdr.digimin(idx_channel_rem,:) = [];
    header.hdr.digimax(idx_channel_rem,:) = [];
    header.hdr.prefilt(idx_channel_rem,:) = [];
    header.hdr.numbersperrecord(idx_channel_rem,:) = [];
end

end