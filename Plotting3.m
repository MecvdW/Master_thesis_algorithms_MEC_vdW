figure;
ticks = 0:0.5:length(eoglm2)/60/60/readme.fs_original(1);
axis tight
hypnogramplt = repelem(hypnogram,30*readme.fs_original(1));
ylim([-4 2]); xticks(ticks(1:end-1));
%xlim(subplt1,[0 length(t)])
title('1=W, 0=REM, -1=N1, -2=N2, -3=N3, Raw Data'); plot(t,hypnogramplt); 