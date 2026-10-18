function vReplica = fctTrackingReplicaGen(sState, sConfig, dArmOffset, dTimeOffset)
    %% Continuous code/carrier replica for one integration block.
    % dTimeOffset = 0: current block; -T: previous block for FLL re-correlation.
    dFs = sConfig.signal.sampleRate_Hz;
    dT = sConfig.assumptions.integrationTime_ms * 1e-3;
    iNumSample = round(dFs * dT);
    vLocalTime = dTimeOffset + (0:iNumSample - 1) / dFs;
    vAbsoluteTime = sState.dTime + vLocalTime;
    vPhaseIncrement = sState.dDoppler * vLocalTime ...
        + 0.5 * sState.dDopplerRate * vLocalTime.^2;
    vCarrierPhase = sState.dCarrierPhase + vPhaseIncrement;
    vDelay = sState.dCodeDelay + dArmOffset ...
        - sConfig.design.dll.carrierToCodeScale * vPhaseIncrement;
    vChipIndex = mod(floor(sConfig.assumptions.codeRate_Hz * vAbsoluteTime - vDelay),1023) + 1;
    vCarrier = exp(2i * pi * (sConfig.signal.intermediateFrequency_Hz * vAbsoluteTime + vCarrierPhase));
    vReplica = sState.vCode(vChipIndex) .* vCarrier;
end
