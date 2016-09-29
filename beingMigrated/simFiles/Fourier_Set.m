
%% Test Fourier 
%% Geoff's Implementation

% n = HRF duration-- Time Set (seconds)
% m = Fourier Set Matrix
% t = Time Points (HRF duration)
%n = HRFduration ;
n = 16 ; %example

if mod(n,2) == 1

    % n is odd
    t = linspace(0,n-1,n);
    m = zeros(n,n);
    m(1,:) = ones(n,1);

    for i = 1:(n-1)/2
        m(i*2,:) = sin(t/n*2*pi*i);

        m(i*2+1,:) = cos(t/n*2*pi*i);
    end
    
elseif mod(n,2) == 0

    % n is even
    t = linspace(0,n-1,n);
    m = zeros(n,n);
    m(1,:) = ones(n,1);

    for i = 1:n/2-1
        m(i*2,:) = sin(t/(n-1)*2*pi*i);
        m(i*2+1,:) = cos(t/(n-1)*2*pi*i);
    end
    
else
    t = linspace(0,n-1,n);
    m = zeros(n,n);
end

m(n,:) = sin(t/(n-1)*2*pi*(n/2));

%% Time specifications:
% Fs = 16;                   % samples per second
% dt = 1/Fs;                 % seconds per sample
% %dt = 1;
% n = 16;               % Fourier time Set (seconds)
% t = (0:dt:n-dt)';     % seconds
% close all 
% 
% 
% 
% %% Waves:
% cosine_waves = [] ;
% sine_waves   = [] ;
% 
% % DC Component:
% DC_component = ones(length(t),1);
% 
% % Cosine wave:
% for i = 1:n/2 -1
%     Fc = i/16 ;                     % hertz (# of loops per time period)
%     cosine = cos(2*pi*Fc*t) ;
%     cosine_waves(:,i) = cosine ;
% end
% 
% 
% % Sine Wave:
% for j = 1:n/2 -1
%     Fc = j/n ;               % hertz (# of loops per time period)
%     sine = sin(2*pi*Fc*t) ;
%     sine_waves(:,j) = sine ;
% end
% 
% % Nyquist                           % Take time period /2 for nyquist
% h = floor(n/2) ;             % Round number to next smallest integer
% Fc = h/n ;
% Nyquist = sin(2*pi*Fc*t) ;
% 
% 
% figure;
% set(gcf,'Position',[187 216 2252 1085]);
% 
% %% Plotting
% 
% for k = 1:n/2 -1             % Not including the Nyquist
%     
%     % Plot DC component
%     subplot(n/2+1,1,1)       % Subplot is # of sets + DC component
%     plot(t,DC_component,'-k') ;
%     xlabel('time (s)');
%     title('DC Component'); 
%     zoom xon ;
%     hold on ;
%     legend('DC_comp', 'Location','northeastoutside','Orientation','vertical') 
%     
%     % Plot Sin
%     subplot(n/2+1,1,k+1)
%     plot(t,sine_waves(:,k),'-b')
%     xlabel('time (s)');
%     title('Signal vs Time'); 
%     zoom xon ;
%     hold on ;
%     
%     % Plot Cos
%     subplot(n/2+1,1,k+1)
%     plot(t,cosine_waves(:,k),'-r')
%     xlabel('time (s)');
%     title('Signal vs Time'); 
%     zoom xon ;
%     hold on ;
%     legend('si(x)','cos(x)','Location','northeastoutside','Orientation','vertical')
%     
%     % Plot Nyquist
%     subplot(n/2+1,1,n/2+1)
%     plot(t,Nyquist,'-b')
%     xlabel('time (s)');
%     title('Nyquist'); 
%     zoom xon ;
%     hold on ;
%     legend('Nyquist', 'Location','northeastoutside','Orientation','vertical') 
%     
%    
% end
