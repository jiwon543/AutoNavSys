%% Task2
fprintf("---------- Task2 ----------  \n")
%%
load(fullfile('..', 'Data', 'IncomingIF.mat'));
vIF = IncomingIF(1, :);

dTs = 1 / 5.714e6; % [sec]
dFs = 1 / dTs; % [Hz]
dL = length(vIF);
vt = (0 : dL - 1) * dTs; % Time Series
vIFfft = fftshift(fft(vIF)); % Fourier Transform
vPSD = abs(vIFfft).^2 / (dFs * dL);
vFs = (-dL/2 : dL/2-1) * (dFs/dL);

figure;
subplot(1,2,1);
plot(vt, vIF, 'b', 'LineWidth', 1.0);
grid on;
ylim([-5 5]);
xlabel('Time'); ylabel('Amplitude');
title('Time serires of IF data')

subplot(1,2,2);
plot(vFs, vPSD, 'b', 'LineWidth', 1.0);
grid on;
xlabel('Frequency'); ylabel('Power');
title('PSD of IF data')
%%
fprintf("===== Task2: Complete ===== \n\n")