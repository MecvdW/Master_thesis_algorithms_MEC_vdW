ind = 352;

N = length(eoglm230s(:,ind));
nfft = 2^(2+nextpow2(N));
[PxxL, fL] = periodogram(eoglm230s(:,ind),hann(N),nfft,readme.fs_original(1));
N = length(eogrm230s(:,ind));
nfft = 2^(2+nextpow2(N));
[PxxR, fR] = periodogram(eogrm230s(:,ind),hann(N),nfft,readme.fs_original(1));
figure;
subplot(2,1,1)
plot(fL(1:641,1),PxxL(1:641,1))
subplot(2,1,2)
plot(fR(1:641,1),PxxR(1:641,1))
sgtitle('Energy of epoch, REM sleep, Upper = Left, Lower = Right')



