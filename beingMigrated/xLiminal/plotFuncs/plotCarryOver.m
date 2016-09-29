function plotCarryOver(uniqueTempFreq,finalCarryOverMat,type,stimName)

% function plotCarryOver(uniqueTempFreq,finalCarryOverMat,type)
if strcmp(type,'Amplitude')
    figure; set(gcf,'Position',[391 470 1096 420]);

    subplot(1,3,1);
    imagesc(finalCarryOverMat)
    title([stimName '' type]); set(gca,'xticklabel',(uniqueTempFreq)); set(gca,'xtick',(1:7));
    set(gca,'yticklabel',(uniqueTempFreq)); xlabel('Preceding stimulus (Hz)');
    ylabel('Stimulus'); set(gca,'FontSize',15); colorbar; axis square;

    uniqueTempFreqToPlot = uniqueTempFreq;
    uniqueTempFreqToPlot(uniqueTempFreqToPlot==0) = 1;

    subplot(1,3,2);
    plot(uniqueTempFreqToPlot,mean(finalCarryOverMat,2),'-ko','LineWidth',1.5,'MarkerSize',10); 
    axis square; set(gca,'Xscale','log'); set(gca,'xtick',(uniqueTempFreqToPlot));
    set(gca,'xticklabel',(uniqueTempFreq)); set(gca,'FontSize',15); xlabel('Stimulus (Hz)'); 
    ylabel(type); title('Direct effect'); 

    subplot(1,3,3);
    plot(uniqueTempFreqToPlot,mean(finalCarryOverMat,1),'ko','LineWidth',1.5,'MarkerSize',10); hold on
    axis square; set(gca,'Xscale','log'); set(gca,'xtick',(uniqueTempFreqToPlot));
    set(gca,'xticklabel',(uniqueTempFreq));set(gca,'FontSize',15);
    xlabel('Preceding stimulus (Hz)'); ylabel(type); title('Preceding effect'); xlim([min(uniqueTempFreqToPlot).*0.9 max(uniqueTempFreqToPlot).*1.1]);

    [m, c, fit]= fitCarryOverMarg(mean(finalCarryOverMat,2),mean(finalCarryOverMat,1));
    plot(uniqueTempFreqToPlot,fit,'--k','LineWidth',1.5,'MarkerSize',10);

    xText = xlim; yText = ylim;
    text(xText(2)./8,yText(2).*0.9,['scale = ' num2str(m)],'FontSize',15);
    
elseif strcmp(type,'tau2')
    figure; imagesc(finalCarryOverMat)
    title([stimName '' type]); set(gca,'xticklabel',(uniqueTempFreq));
    set(gca,'yticklabel',(uniqueTempFreq)); xlabel('Preceding stimulus (Hz)');
    ylabel('Stimulus'); set(gca,'FontSize',15); colorbar;
else
   error('plotCarryOver: SPECIFY VALID PARAMETER TYPE: 1) Amplitude or 2) tau2'); 
end

end