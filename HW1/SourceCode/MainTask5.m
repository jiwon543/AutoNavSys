%% Task5
fprintf("---------- Task5 ----------  \n")

%% Signal Parameter
iPRN = 13;

dCodeDelay = 201.3;      % [chip]
dInitCarrierPhase = 0;   % [cycle]
dDoppler = 3e3;          % [Hz]
dCN0 = 40;               % [dB-Hz]
dIntTime = 10;           % [ms]
fprintf('Integration Time: %2d [ms] \n', dIntTime);

%% Signal Generation
GeneratedIncomingIF = fctRcvSigGen(iPRN, dCodeDelay, dInitCarrierPhase, dDoppler, dCN0, dIntTime);

%% Acquisition
sParAcq = fctParallelAcq(GeneratedIncomingIF, 1023, 0.1, 250, dIntTime);

%% Selection
tAcqResult = fctSelection(sParAcq, 0.001);
disp(tAcqResult);

%% Computation Time
fprintf('Parallel Acquisition Time: %.3f sec\n', sParAcq.dTime);

%% Plot
figure;
fctPlotAcq3D(sParAcq, iPRN);

%%
fprintf("===== Task5: Complete ===== \n\n")