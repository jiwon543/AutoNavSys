%% Task 4 - Acquisition and tracking of the saved GPS IF
%% Directory
sHW2Root = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(sHW2Root,'SourceCode','function')));
sConfig4 = jsondecode(fileread(fullfile(sHW2Root,'Data','Task4.json')));
sConfig3 = fctLoadTask3Config(fullfile(sHW2Root,'Data','Task3.json'));
sDataFile = fullfile(sHW2Root,'Data',sConfig4.output.file);
sOut4 = fullfile(sHW2Root,sConfig4.output.directory);
if ~exist(sOut4,'dir'), mkdir(sOut4); end

%% Load, Run and Save
sIFData = load(sDataFile);
sTask4 = fctRunTask4(sIFData, sConfig4, sConfig3);
fctPlotTask4(sTask4, sConfig4, sOut4);
fctSaveTask4(sTask4, sConfig4, sConfig3, sOut4);
