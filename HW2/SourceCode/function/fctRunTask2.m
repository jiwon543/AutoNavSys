function sResult = fctRunTask2(sConfig)
    %% Run Task2    
    %% Analytical correlator model, not a second IF simulation.
    %% Read the Parameter (Configurations)
    rng(sConfig.randomSeed, 'twister');
    dT = sConfig.integrationTime_ms * 1e-3;
    sRange = sConfig.phaseDifference_rad;
    vPhaseDifference = (sRange.start : sRange.step : sRange.stop).';
    sRange = sConfig.codeError_chip;
    vCodeError = (sRange.start : sRange.step : sRange.stop).';
    vAmplitude = sConfig.amplitudes(:).';
    iNumAmplitude = numel(vAmplitude);
    aFLL = zeros(numel(vPhaseDifference), 3, iNumAmplitude); 
    mRawCross = zeros(numel(vPhaseDifference),iNumAmplitude);
    mDLL = zeros(numel(vCodeError), iNumAmplitude);
    dMaxCrossError = 0; 
    dMaxDotError = 0; 
    dMaxFLLError = 0; 
    dMaxDLLError = 0;
    dInitialPhase = sConfig.monteCarlo.initialPhase_rad;

    
    mFLLTheory = [sin(vPhaseDifference), sin(vPhaseDifference) .* sign(cos(vPhaseDifference)), atan2(sin(vPhaseDifference), cos(vPhaseDifference))] / (2 * pi * dT);
    for iAmplitude = 1:iNumAmplitude
        dAmplitude = vAmplitude(iAmplitude);
        vPrompt1 = dAmplitude * exp(1i * dInitialPhase) * ones(size(vPhaseDifference));
        vPrompt2 = dAmplitude * exp(1i * (dInitialPhase + vPhaseDifference));
        
        % Independently expand the I/Q products, then compare to identities.
        vCross = real(vPrompt1) .* imag(vPrompt2) - imag(vPrompt1) .* real(vPrompt2);
        vDot = real(vPrompt1) .* real(vPrompt2) + imag(vPrompt1) .* imag(vPrompt2);
        dMaxCrossError = max(dMaxCrossError, max(abs(vCross - dAmplitude^2 * sin(vPhaseDifference))));
        dMaxDotError = max(dMaxDotError, max(abs(vDot - dAmplitude^2 * cos(vPhaseDifference))));
        mRawCross(:, iAmplitude) = vCross / (2 * pi * dT);
        aFLL(:, :, iAmplitude) = fctDiscFLL(vPrompt1, vPrompt2, dT);
        mError = aFLL(:, :, iAmplitude) - mFLLTheory;
        
        % At +/-pi, atan2 may select either endpoint due to roundoff.
        % Compare the atan2 output modulo its 1/T frequency period.
        mError(:, 3) = angle(exp(2i * pi * dT * mError(:, 3))) / (2 * pi * dT);
        dMaxFLLError = max(dMaxFLLError, max(abs(mError), [], 'all'));
        vEarly = dAmplitude * max(1-abs(vCodeError -.5), 0);
        vPrompt = dAmplitude * max(1-abs(vCodeError), 0);
        vLate = dAmplitude * max(1-abs(vCodeError +.5), 0);
        mDLLResult = fctDiscDLL([vEarly, vPrompt, vLate]);
        mDLL(:,iAmplitude) = mDLLResult(:, 1);
        dMaxDLLError = max(dMaxDLLError, max(abs(mDLL(:, iAmplitude) - vCodeError)));
    end
    assert(max([dMaxCrossError, dMaxDotError, dMaxFLLError, dMaxDLLError]) < 1e-9,'Discriminator identity check failed.');

    % Complex post-integration AWGN: variance per I/Q = A^2/(2*CN0*T).
    % E/P/L noises are approximated as independent for this illustration.
    % Real E/P/L correlator noises share IF samples and are correlated.
    vCN0 = sConfig.monteCarlo.cn0_dBHz(:);
    iNumTrial = sConfig.monteCarlo.trials;
    dFrequencyError = sConfig.monteCarlo.frequencyError_Hz;
    dCodeError = sConfig.monteCarlo.codeError_chip;
    mNoiseStatistics = zeros(numel(vCN0), 13);
    vIdealFLL = [sin(2 * pi * dFrequencyError * dT), ...
        sin(2 * pi * dFrequencyError * dT) * sign(cos(2 * pi * dFrequencyError * dT)), ...
        2 * pi * dFrequencyError * dT] / (2 * pi * dT);
    
    for iCN0 = 1:numel(vCN0)
        dNoiseStd = sqrt(1 / (2 * 10^(vCN0(iCN0) / 10) * dT));
        vPrompt1 = exp(1i * dInitialPhase) + dNoiseStd * (randn(iNumTrial, 1) + 1i * randn(iNumTrial, 1));
        vPrompt2 = exp(1i * (dInitialPhase+2 * pi * dFrequencyError * dT))+dNoiseStd * (randn(iNumTrial, 1) + 1i * randn(iNumTrial, 1));
        mFrequencyEstimate = fctDiscFLL(vPrompt1, vPrompt2, dT);
        mEPL = exp(1i * dInitialPhase) * [.5 + dCodeError, 1 - abs(dCodeError), .5 - dCodeError] ...
            + dNoiseStd * (randn(iNumTrial, 3) + 1i * randn(iNumTrial, 3));
        mDLLResult = fctDiscDLL(mEPL); 
        vDelayEstimate = mDLLResult(:,1);
        vBias = mean(mFrequencyEstimate, 1) - dFrequencyError;
        vStd = std(mFrequencyEstimate, 0, 1);
        vRMSE = sqrt(mean((mFrequencyEstimate - dFrequencyError).^2, 1));
        mNoiseStatistics(iCN0,:) = [vCN0(iCN0), vBias, vStd, vRMSE, mean(vDelayEstimate) - dCodeError, std(vDelayEstimate), sqrt(mean((vDelayEstimate - dCodeError).^2))];
    end
    cColumnName = {'CN0_dBHz','CrossBias_Hz','SignBias_Hz','Atan2Bias_Hz', ...
        'CrossStd_Hz','SignStd_Hz','Atan2Std_Hz','CrossRMSE_Hz','SignRMSE_Hz','Atan2RMSE_Hz', ...
        'DLLBias_chip','DLLStd_chip','DLLRMSE_chip'};
    sResult = struct('phaseDifference_rad', vPhaseDifference, 'codeError_chip', vCodeError, 'amplitudes', vAmplitude, ...
        'fll', aFLL, 'rawCross', mRawCross, 'fllTheory', mFLLTheory, 'dll', mDLL, 'idealFLL_Hz', vIdealFLL, ...
        'maxIdentityError', [dMaxCrossError, dMaxDotError, dMaxFLLError, dMaxDLLError], ...
        'tNoise', array2table(mNoiseStatistics, 'VariableNames', cColumnName));
end
