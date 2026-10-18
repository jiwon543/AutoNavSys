function sTask1 = fctRunTask1(sConfig)
    %% Run Task1
    % Run three-experiments:
    % Without AWGN  : CodeDelay | Doppler | CarrierPhase
    %%
    % 1) Read parameters; configurations
    % 2) [fctTask1Sweep] Run three-experiments
    %                   -> Change Parameters
    %                   -> E/P/L Correlation
    %                   -> Compute Discriminator

    %% Read the Parameter (Configurations)
    iPRN = sConfig.truth.prn;
    dCodeTruth = sConfig.truth.codeDelay_chip;
    dPhaseTruth = sConfig.truth.carrierPhase_cycle;
    dDopplerTruth = sConfig.truth.doppler_Hz;
    
    %% Adjacent epoch spacing equals the integer sample count / sample rate.
    dDuration_ms = 2 * sConfig.tracking.integrationTime_ms;
    cRange = {sConfig.sweep.code_chip, sConfig.sweep.doppler_Hz, sConfig.sweep.phase_cycle};
    cError = cellfun(@(s) s.start : s.step : s.stop, cRange, 'UniformOutput', false);
    vReceived = fctRcvSigGen(iPRN, dCodeTruth, dPhaseTruth, dDopplerTruth, Inf, dDuration_ms, sConfig.signal);
    
    %% Run the 'fctTask1Sweep'; Run three-experiments
    cResult = cell(3,1);
    for iSweep = 1:3
        % ===== Run fctTask1Sweep =====
        cResult{iSweep} = fctTask1Sweep(cError{iSweep}, vReceived, iSweep, sConfig);
        % ===== ===== ===== ===== =====
    end
    % OUTPUT 반환
    sTask1 = reshape([cResult{:}],3,1);
end

%% One independent noise-free sweep
function sResult = fctTask1Sweep(vError,vReceived,iSweep,sConfig)
    % Config.
    iPRN = sConfig.truth.prn;
    dCodeTruth = sConfig.truth.codeDelay_chip;
    dPhaseTruth = sConfig.truth.carrierPhase_cycle;
    dDopplerTruth = sConfig.truth.doppler_Hz;
    dSpacing = sConfig.tracking.earlyLateOffset_chip;
    dT = sConfig.tracking.integrationTime_ms*1e-3;
    
    % Pre-Allocation
    mFirst = zeros(numel(vError),3);
    mSecond = zeros(numel(vError),3);
    
    % SWEEP: CodeDelay | Doppler | CarrierPhase
    for i = 1:numel(vError)
        dDelay = dCodeTruth; 
        dPhase = dPhaseTruth; 
        dDopp = dDopplerTruth;

        switch iSweep
            case 1, dDelay = dDelay + vError(i);
            case 2, dDopp = dDopp + vError(i);
            case 3, dPhase = dPhase + vError(i);
        end

        mZ = fctCorrelateEPL(vReceived, iPRN, dDelay, dPhase, dDopp, dSpacing, sConfig);
        mFirst(i,:) = mZ(1,:);
        mSecond(i,:) = mZ(2,:);
    end
    
    sResult = struct('vError',vError,'mFirst',mFirst,'mSecond',mSecond, ...
        'mDLL',fctDiscDLL(mFirst),'mPLL',fctDiscPLL(mFirst(:,2)), ...
        'mFLL',fctDiscFLL(mFirst(:,2),mSecond(:,2),dT));
end
