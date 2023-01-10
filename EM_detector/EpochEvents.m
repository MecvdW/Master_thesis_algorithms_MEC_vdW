% This function is part of  the master thesis ‘Machine learning design for
% analysis of neurodegenerative diseasesa at DTU from June 2022 to January
% 2023, written by Maria Elisabeth Catharina (Marleen) van der Weij,
% s222071/s1800078

function Events = EpochEvents(EM, events, fs, i)
% Epoch length
EP = (((i*30*fs)+1)-(30*fs):i*30*fs);
% Find events in every epoch apart --> EMs
Events1 = EM(ismember(EM(:,1),EP),1);
Events2 = EM(ismember(EM(:,2),EP),2);
% Correct for events going over the borders of the epoch
if events == 1
    if isempty(Events1) && isempty(Events2)
        Events1 = EP(1);
        Events2 = EP(end);
    elseif isempty(Events2)
        Events2 = EP(end);
        while length(Events1) > length(Events2)
            Events2 = [Events2; EP(end)];
        end
    elseif isempty(Events1)
        Events1 = EP(1);
        while length(Events2) > length(Events1)
            Events1 = [EP(1); Events1];
        end
    elseif length(Events1) > length(Events2)
        Events2 = [Events2; EP(end)];
        while length(Events1) > length(Events2)
            Events2 = [Events2; EP(end)];
        end
    elseif length(Events2) > length(Events1)
        Events1 = [EP(1); Events1];
        while length(Events2) > length(Events1)
            Events1 = [EP(1); Events1];
        end
    end
elseif events == 0 && isempty(Events1) && isempty(Events2)
    Events1 = 0;
    Events2 = 0;
elseif events == 0
    if isempty(Events1)
        Events1 = EP(1);
        while length(Events2) > length(Events1)
            Events1 = [EP(1); Events1];
        end
    elseif isempty(Events2)
        Events2 = EP(end);
        while length(Events1) > length(Events2)
            Events2 = [Events2; EP(end)];
        end
    elseif length(Events1) > length(Events2)
        Events2 = [Events2; EP(end)];
        while length(Events1) > length(Events2)
            Events2 = [Events2; EP(end)];
        end
    elseif length(Events2) > length(Events1)
        Events1 = [EP(1); Events1];
        while length(Events2) > length(Events1)
            Events1 = [EP(1); Events1];
        end
    end
end
Events = [Events1 Events2];
end