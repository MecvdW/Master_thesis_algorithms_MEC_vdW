for i = 2:length(CorrCoefLR)
    corrC = CorrCoefLR{i(1)};
    corr(i) = corrC(1,2);
end

figure;
subplot(2,1,1)
plot(hypnogram)
subplot(2,1,2)
plot(corr);sgtitle('Correlation coefficient between Left and Right EOG');xlabel('30s epochs');ylabel('Correlation coefficient')
