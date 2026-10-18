%% Task3
fprintf("---------- Task3 ----------  \n")
%% Run function of Conventional Acquisition Method
% (Conventional Acquisition Total execution time: 252.12 seconds)
%load(fullfile('..', 'Data', 'IncomingIF.mat'));
%vIF = IncomingIF(1, :);
%addpath('function');
%sConvAcq = fctConvenAcq(vIF, 1023);

%% Load Result
load(fullfile('..', 'Result', 'sConvAcq.mat'));

%% Selection
tAcqResult = fctSelection(sConvAcq, 0.001);
disp(tAcqResult);
fprintf('Conventioanl Acquisition Time: %.3f sec\n', sConvAcq.dTime);
%% Plot
iPRN1 = 1;
iPRN2 = 2;
mAcq1 = squeeze(sConvAcq.mPower(iPRN1, :, :));
mAcq2 = squeeze(sConvAcq.mPower(iPRN2, :, :));
dCmax = max([mAcq1(:); mAcq2(:)]);

% 2D Plot
figure;
subplot(1,2,1);
fctPlotAcq2D(sConvAcq, iPRN1, dCmax);
subplot(1,2,2);
fctPlotAcq2D(sConvAcq, iPRN2, dCmax);

% 3D Plot
figure;
subplot(1,2,1);
fctPlotAcq3D(sConvAcq, iPRN1);
subplot(1,2,2);
fctPlotAcq3D(sConvAcq, iPRN2);

%%
fprintf("===== Task3: Complete ===== \n\n")