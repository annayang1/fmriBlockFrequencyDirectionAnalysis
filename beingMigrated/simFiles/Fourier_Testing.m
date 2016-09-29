fullFigure;
numFreqs = [16 25 33 35];
scaleFactor = 10000;
for i = 1:length(numFreqs)
    sampT                   = 1000; % TR (msec)
    eventTimes              = [12200 17325 33300 55500 60320 88800]; % attention events (msec)
    HRFdur                  = numFreqs(i) * 1000; % msec 
    %HRFdur                  = 30000; % msec
    % Make fake data
    hrf                     = doubleGammaHrf(1/sampT,[6 10],[1 1],0,HRFdur/1000); % HRF in sec
    hrf                     = hrf * scaleFactor;
    tmpTC                   = zeros(100000,1);
    tmpTC(eventTimes)       = 1;
    upTC         = filter(hrf,1,tmpTC);
    % add some noise
    nupTC                   = upTC + 0*max(upTC)*randn(size(upTC));
    timeSeries              = downsample(nupTC,sampT);
    %
    subplot(1,4,i);
    [HRF,betaValues,fSet,estTC,numCov] = deriveHRF(timeSeries,eventTimes,sampT,HRFdur,numFreqs(i));
    % Plot
    x = 1:length(HRF);
    plot(x,HRF,'b',x,hrf,'r');
    xlim([0 35000]);
    axis square;
    xlabel('Time (TRs)','FontSize',20);
    ylabel('Percent Signal Change','FontSize',20);
    legend({'Fourier model' 'Simulated data'},'FontSize',10);
    title(['nFreqs = ' num2str(numCov) ],'FontSize',20);
end
%%
for i = 1:length(betaValues)
    tmp(i,:) = betaValues(i) * fSet(:,i);
end
%%
figure;
for i = 1:size(fSet,2);
    subplot(7,10,i);
    plot(fSet(:,i));
    xlim([0 33000]);
end
Add Comment Coll