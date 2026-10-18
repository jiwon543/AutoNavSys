%% Task 2 - Numerical verification of discriminator derivations
%% Driectory
sHW2Root = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(sHW2Root,'SourceCode','function')));
sConfig2 = fctLoadTask2Config(fullfile(sHW2Root,'Data','Task2.json'));
sOut2 = fullfile(sHW2Root,sConfig2.output.directory);
if ~exist(sOut2,'dir'), mkdir(sOut2); end

%% Run 
sTask2 = fctRunTask2(sConfig2);
fctPlotTask2(sTask2,sConfig2,sOut2);
save(fullfile(sOut2,'Task2.mat'),'sTask2','sConfig2');
writetable(sTask2.tNoise,fullfile(sOut2,'NoiseStatistics.csv'));
fprintf('Task 2 complete. Algebra checks passed. Results: %s\n',sOut2);
