%% HW3 Task 2 - Error-state Kalman filter, linear discriminator measurements
%% Directory
if ~exist('sConfig', 'var') || ~exist('cLoop', 'var')
    run(fullfile(fileparts(mfilename('fullpath')), 'MainTask1.m'));
end

%% Kalman Filter
cKF = cell(size(cLoop));
for iCh = 1:numel(sConfig.channels)
    iChannel = sConfig.channels(iCh);
    cKF{iCh} = fctRunBaseband(sTruth(iChannel), sConfig, 'KF');
    fctPlotHW3(sTruth(iChannel), cLoop{iCh}, cKF{iCh}, sConfig);
end
save(fullfile(sConfig.resultDir, 'Task2.mat'), 'cKF', 'cLoop', 'sConfig');
fctSummaryHW3(cLoop, cKF, sConfig);
