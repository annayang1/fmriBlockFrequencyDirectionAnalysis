
%% Fake Data to test Fourier & FIR

addpath('/Users/Shared/mriTemporalFitting/');

Time_Samples = 0:335;
Fake_Data = zeros(1,length(Time_Samples)) ;

AttnStartTimes = 1000*[ 21.6630000000000;...
29.5720000000000; 77.9870000000000; 139.510000000000; ...
159.030000000000; 224.090000000000; 234.130000000000; ...
291.280000000000; 308.820000000000; 320.610000000000; ...
333.530000000000] ;

% AttnStartTimes = [224.09];

AttnRound = round(AttnStartTimes) ;

Rndnumbers = AttnRound;

for i = 1:length(Rndnumbers)
    Temp = Rndnumbers(i) ;
    Fake_Data(Temp+1) = 1 ;
end 
%% --------


sampT = 800;

AttnStartTimes = 1000*[ 21.6630000000000;...
29.5720000000000; 77.9870000000000; 139.510000000000; ...
159.030000000000; 224.090000000000; 234.130000000000; ...
291.280000000000; 308.820000000000; 320.610000000000; ...
333.530000000000] ;

fakeTC                  = zeros(336000,1);
fakeTC(AttnStartTimes)  = 1;

gamma1 = 6; gamma2 = 12; gammaScale = 10; HRFexpectedLength = 16;

tStamps = 0:0.001:16;
bHRF = createCanonicalHRF(tStamps,gamma1,gamma2,gammaScale);

UPS_TimeSamples         = filter(bHRF,1,fakeTC);

timeSeries = downsample(UPS_TimeSamples,sampT);

plot(tStamps,bHRF,'k',tStamps,bHRF,'ro') ;

timeSeries = filter(bHRF,1,Fake_Data) ;

eventTimes = 1000 * AttnStartTimes ;


