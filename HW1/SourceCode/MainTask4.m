%% Task4
fprintf("---------- Task4 ----------  \n")

%% Load IF Data
load(fullfile('..', 'Data', 'IncomingIF.mat'));

%% First 1 ms IF Data
vIF = IncomingIF(1, :);

%% Parallel Acquisition
sParAcq = fctParallelAcq(vIF, 1023, 0.5, 250);

%% Selection
tParAcqResult = fctSelection(sParAcq, 0.001);
disp(tParAcqResult);

%% Computation Time
fprintf('Parallel Acquisition Time: %.3f sec\n', sParAcq.dTime);

%%
fprintf("===== Task4: Complete ===== \n\n")