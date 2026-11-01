%% HW3 Task 1 - Baseband Model
%% Directory
if ~exist('sConfig', 'var')
    sHW3Root = fileparts(fileparts(mfilename('fullpath')));
    addpath(genpath(fullfile(sHW3Root, 'SourceCode', 'function')));
    sConfig = fctConfigHW3(sHW3Root);
end

%% Load Truth file
sData = load(sConfig.truthFile, 'ChSignalParameterTruth');
sTruth = sData.ChSignalParameterTruth;
fctTestBaseband(sConfig);

%% Baseband Simulator
cLoop = cell(1, numel(sConfig.channels));
for iCh = 1:numel(sConfig.channels)
    iChannel = sConfig.channels(iCh);
    cLoop{iCh} = fctRunBaseband(sTruth(iChannel), sConfig, 'Loop');
    fctPlotHW3(sTruth(iChannel), cLoop{iCh}, [], sConfig);
end
save(fullfile(sConfig.resultDir, 'Task1.mat'), 'cLoop', 'sConfig');
