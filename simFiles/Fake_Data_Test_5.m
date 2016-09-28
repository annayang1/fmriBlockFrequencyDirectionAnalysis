
%% Fake Data to test Fourier & FIR

addpath('/Users/Shared/mriTemporalFitting/');

Time_Samples = 0:335 ;
Fake_Data = zeros(1,length(Time_Samples)) ;

AttnStartTimes = [ 21.6630000000000;...
29.5720000000000; 77.9870000000000; 139.510000000000; ...
159.030000000000; 224.090000000000; 234.130000000000; ...
291.280000000000; 308.820000000000; 320.610000000000; ...
333.530000000000] ;

% AttnStartTimes = [224.09];
Rndnumbers = round(AttnStartTimes) ;
attnStartTimes = AttnStartTimes .* 1000 ;


for i = 1:length(Rndnumbers)
    Temp = Rndnumbers(i) ;
    Fake_Data(Temp+1) = 1 ;
end 
% --------
gamma1 = 6; gamma2 = 12; gammaScale = 10; HRFexpectedLength = 34;

BOLDHRF = createCanonicalHRF(Time_Samples,gamma1,gamma2,gammaScale);
BOLDHRFtoTest = createCanonicalHRF(0:HRFexpectedLength,gamma1,gamma2,gammaScale);
% --------

Fake_TimeSeries = conv(Fake_Data,BOLDHRF) ;
Fake_TimeSeries = Fake_TimeSeries(1:length(Time_Samples)) ;

% Apprach 1 -- Original Fourier -- (s resolution)
[hrf] = attentionFourier(Time_Samples,Fake_TimeSeries,AttnStartTimes,HRFexpectedLength,1) ;
hrf = hrf .* 1000 ;
HRF_LR = hrf ;
clear hrf ;

% Approach 2 -- Drop Fourier Cassete at Nearest TR -- (UPsampled: ms Resolution)
[HRF] = deriveHRF_NTR(Fake_TimeSeries',attnStartTimes,1000,34000,34) ;
HRF_NTR = HRF ; 
clear HRF ;

% Approach 3 -- Drop Fourier Cassete at Event Sart Time -- (UPsampled: ms Resolution) 
[HRF] = deriveHRF(Fake_TimeSeries',attnStartTimes,1000,34000,34) ;
HRF_EST = HRF ; 
clear HRF ;

% Approach 4 -- Phase Shift -- (UPsampled: ms Resolution)
[HRF] = deriveHRF_PS(Fake_TimeSeries',attnStartTimes,1000,34000,34) ;
HRF_PS = HRF ; 
clear HRF ;


%% Old Fourier Script

% % Apprach 1 -- Original Fourier -- (s resolution)
% [hrf] = attentionFourier(Time_Samples,Fake_TimeSeries,AttnStartTimes,HRFexpectedLength,1) ;
% hrf_Fourier_LR = hrf ;
% hrf_Fourier_LR = hrf_Fourier_LR - hrf_Fourier_LR(1) ;
% clear hrf ;
% 
% % Approach 2 -- Drop Fourier Cassete at Nearest TR -- (UPsampled: ms Resolution)
% [hrf] = Derive_HRF_using_Fourier_NTR(Time_Samples,Fake_TimeSeries,AttnStartTimes,HRFexpectedLength,1) ;
% hrf_Fourier_NTR = hrf ;
% hrf_Fourier_NTR = hrf_Fourier_NTR - hrf_Fourier_NTR(1);
% clear hrf ;
% 
% % Approach 3 -- Drop Fourier Cassete at Event Sart Time -- (UPsampled: ms Resolution)
% [hrf] = Derive_HRF_using_Fourier_EST(Time_Samples,Fake_TimeSeries,AttnStartTimes,HRFexpectedLength,1);
% hrf_Fourier_EST = hrf ;
% hrf_Fourier_EST = hrf_Fourier_EST - hrf_Fourier_EST(1);
% clear hrf ;
% 
% % Approach 4 -- Phase Shift -- (UPsampled: ms Resolution)
% [hrf] = Derive_HRF_using_Fourier_PS(Time_Samples,Fake_TimeSeries,AttnStartTimes,HRFexpectedLength,1) ;
% hrf_Fourier_PS = hrf ;
% hrf_Fourier_PS = hrf_Fourier_PS - hrf_Fourier_PS(1) ;
% clear hrf ;
% 
% % Approach 5 -- FIR
% [hrf] = attentionFIR(Time_Samples,Fake_TimeSeries,AttnStartTimes,HRFexpectedLength,1) ;
% hrf_FIR = hrf ;
% hrf_FIR = hrf_FIR - hrf_FIR(1);

%% Plotting
figure ;
% set(gcf,'Position',[401 418 1474 460]);

subplot(1,4,1)
plot(HRF_LR) ; title('Approach 1: 1s Resolution'); axis square;

subplot(1,4,2)
plot(HRF_EST); title('Approach 2: Event Start Time'); axis square;

subplot(1,4,3)
plot(HRF_NTR); title('Approach 3: Nearest Temporal Resolution'); axis square;

subplot(1,4,4)
plot(HRF_PS) ; title('Approach 4: Phase Shift'); axis square;

figure; 
plot(HRF_LR,'k') ;axis square; hold on;
plot(HRF_EST,'r') ;axis square; hold on;
plot(HRF_NTR,'c') ;axis square; hold on;
plot(HRF_PS,'b') ;axis square; hold on;



Graves = 69 ;