%% Task 4 - Generate 10 seconds of GPS IF samples
%% Directory
sHW2Root = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(sHW2Root,'SourceCode','function')));
sConfig4 = jsondecode(fileread(fullfile(sHW2Root,'Data','Task4.json')));
sDataFile = fullfile(sHW2Root,'Data',sConfig4.output.file);

%% Generate and Save
sIFData = fctGenerateTask4IF(sConfig4);
save(sDataFile,'-struct','sIFData','-v7.3');
fprintf('GPS IF saved: %d samples, %.1f s, %s\n', ...
    sIFData.sMetadata.iNumSample,sIFData.sMetadata.dDuration_s,sDataFile);
