%% CHECKS TO MAKE SURE NEW AND OLD BETA VALUES ARE THE SAME
% SINCE THIS IS A SCRIPT AND NOT A FUNCTION, BE SURE TO MAKE SURE THAT THE
% SUBJECT NAME PARAMETERS IN fitBOLDmodel and fitBOLDmodel_old ARE THE SAME

fitBOLDmodel_old
close all
betaMatOLD(1,:) = LightFluxBeta;
betaMatOLD(2,:) = L_minus_M_Beta;
betaMatOLD(3,:) = S_Beta;

fitBOLDmodel
close all
betaMatNEW(1,:) = LightFluxBeta;
betaMatNEW(2,:) = L_minus_M_Beta;
betaMatNEW(3,:) = S_Beta;

for i = 1:size(betaMatOLD)
   plot(betaMatOLD(i,:),betaMatNEW(i,:),'s','MarkerSize',10,'LineWidth',2); axis square; hold on 
   
end
xlabel('Old \beta values'); ylabel('New \beta values');
set(gca,'FontSize',15);
legend('Light flux','L-M','S','Location','EastOutside');
