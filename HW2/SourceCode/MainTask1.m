%% Task 1 - Test Discriminators
%% Directory
sHW2Root = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(sHW2Root,'SourceCode','function')));
sConfig = fctLoadTask1Config(fullfile(sHW2Root,'Data','Task1.json'));
% Output Directory0
sOut = fullfile(sHW2Root,sConfig.output.directory);
if ~exist(sOut,'dir'), mkdir(sOut); end

%% Run
sTask1 = fctRunTask1(sConfig);
fctPlotTask1(sTask1,sConfig,sOut);
save(fullfile(sOut,'Task1.mat'),'sTask1','sConfig');
fprintf('Task 1 complete. Results: %s\n',sOut);
