function sData = fctGenerateTask4IF(sConfig)
    %% Generate continuous GPS IF with constant LOS jerk.
    rng(sConfig.randomSeed,'twister');
    dFs = sConfig.signal.sampleRate_Hz;
    dIF = sConfig.signal.intermediateFrequency_Hz;
    iNumSample = round(sConfig.duration_s * dFs);
    iBlockSize = round(sConfig.blockDuration_ms * 1e-3 * dFs);
    sTruth = sConfig.truth;
    vCode = fctCA(sTruth.prn).';
    dJerk = sTruth.losJerk_g_s * sTruth.gravity_m_s2;
    dDopplerSecondDerivative = dJerk / sTruth.l1Wavelength_m;
    dNoiseStd = sqrt(dFs / (2 * 10^(sTruth.cn0_dBHz / 10)));
    assert(iNumSample > 0 && iBlockSize > 0,'Invalid signal length.');
    assert(abs(sConfig.duration_s*dFs-iNumSample)<1e-8,'Duration must span whole samples.');
    assert(abs(sTruth.navigationBit)==1,'Navigation bit must be +1 or -1.');
    iSamplesPerBit = round(sTruth.navigationBitInterval_ms*1e-3*dFs);

    vReceivedSignal = zeros(1,iNumSample,sConfig.output.storageType);
    for iStart = 1:iBlockSize:iNumSample
        iEnd = min(iStart+iBlockSize-1,iNumSample);
        vTime = (iStart-1:iEnd-1) / dFs;
        vPhaseIncrement = sTruth.initialDoppler_Hz * vTime ...
            + 0.5 * sTruth.initialDopplerRate_Hz_s * vTime.^2 ...
            + dDopplerSecondDerivative * vTime.^3 / 6;
        vCodeDelay = sTruth.initialCodeDelay_chip ...
            - sTruth.carrierToCodeScale * vPhaseIncrement;
        vChipIndex = mod(floor(sTruth.codeRate_Hz*vTime-vCodeDelay),1023) + 1;
        vCarrier = cos(2*pi*(dIF*vTime+sTruth.initialCarrierPhase_cycle+vPhaseIncrement));
        vNavigationBit = sTruth.navigationBit * (-1).^floor((iStart-1:iEnd-1)/iSamplesPerBit);
        vSignal = sqrt(2) * vNavigationBit .* vCode(vChipIndex) .* vCarrier;
        vNoise = fctAWGN(0,dNoiseStd,numel(vTime));
        vReceivedSignal(iStart:iEnd) = vSignal + vNoise;
    end

    % Compact truth at integration boundaries, including the endpoint t=10 s.
    dTruthStep = sConfig.truthInterval_ms * 1e-3;
    iNumTruth = round(sConfig.duration_s/dTruthStep);
    assert(dTruthStep>0 && abs(iNumTruth*dTruthStep-sConfig.duration_s)<1e-8, ...
        'Truth interval must divide the duration.');
    sSignalTruth.vTime_s = (0:iNumTruth) * dTruthStep;
    vTime = sSignalTruth.vTime_s;
    vPhaseIncrement = sTruth.initialDoppler_Hz*vTime ...
        + 0.5*sTruth.initialDopplerRate_Hz_s*vTime.^2 ...
        + dDopplerSecondDerivative*vTime.^3/6;
    sSignalTruth.vCarrierPhase_cycle = sTruth.initialCarrierPhase_cycle+vPhaseIncrement;
    sSignalTruth.vDoppler_Hz = sTruth.initialDoppler_Hz ...
        + sTruth.initialDopplerRate_Hz_s*vTime+0.5*dDopplerSecondDerivative*vTime.^2;
    sSignalTruth.vDopplerRate_Hz_s = sTruth.initialDopplerRate_Hz_s+dDopplerSecondDerivative*vTime;
    sSignalTruth.vCodeDelay_chip = sTruth.initialCodeDelay_chip-sTruth.carrierToCodeScale*vPhaseIncrement;
    sSignalTruth.vNavigationBit = sTruth.navigationBit ...
        * (-1).^floor(round(vTime*dFs)/iSamplesPerBit);

    sData.vReceivedSignal = vReceivedSignal;
    sData.sSignalTruth = sSignalTruth;
    sData.sConfig4 = sConfig;
    sData.sMetadata = struct('iNumSample',iNumSample,'dDuration_s',sConfig.duration_s, ...
        'dSampleRate_Hz',dFs,'dSampleInterval_s',1/dFs,'dLastSampleTime_s',(iNumSample-1)/dFs, ...
        'sStorageType',sConfig.output.storageType,'sSignalType','Real IF');
end
