function [sNext, sOutput] = fctTrackingStep(vReceived, sState, sConfig)
    %% Correlator -> Discriminator -> Loop filter -> Single shared state update.
    %% Cofig.
    dT = sConfig.assumptions.integrationTime_ms * 1e-3;
    iNumSample = round(sConfig.signal.sampleRate_Hz * dT);
    assert(isvector(vReceived) && numel(vReceived) == iNumSample, ...
        'TrackingStep needs exactly one integration block.');
    %% Compute I & Q
    vReceived = vReceived(:).';
    vZ = zeros(1,3);
    for iArm = 1:3
        dOffset = (iArm - 2) * sConfig.tracking.earlyLateOffset_chip;
        vReplica = fctTrackingReplicaGen(sState, sConfig, dOffset, 0);
        vZ(iArm) = sqrt(2) * mean(vReceived .* conj(vReplica));
    end
    %% Discriminator & Loop Filter
    vDLL = fctDiscDLL(vZ);
    vPLL = fctDiscPLL(vZ(2));
    dCodeError = vDLL(1);
    dPhaseError = vPLL(sConfig.tracking.pllDiscriminatorColumn);
    dFrequencyError = 0;
    bFllValid = false;
    if sConfig.tracking.fllEnabled && ~isempty(sState.vPreviousIF)
        % Re-correlate the previous block with the SAME current NCO trajectory.
        % Otherwise a PLL phase correction appears as a false FLL frequency.
        vPreviousReplica = fctTrackingReplicaGen(sState, sConfig, 0, -dT);
        dPreviousPrompt = sqrt(2) * mean(sState.vPreviousIF .* conj(vPreviousReplica));
        % Remove the pi ambiguity from data-bit reversals (pull-in: +/-1/(4T) Hz).
        if real(conj(dPreviousPrompt)  *vZ(2)) < 0
            dPreviousPrompt = -dPreviousPrompt;
        end
        vFLL = fctDiscFLL(dPreviousPrompt, vZ(2), dT);
        dFrequencyError = vFLL(sConfig.tracking.fllDiscriminatorColumn);
        bFllValid = isfinite(dFrequencyError);
        if ~bFllValid, dFrequencyError = 0; end
    end
    assert(isfinite(dPhaseError) && isfinite(dCodeError), 'Invalid PLL/DLL discriminator output.');
    sPLL = fctLoopPLL(dPhaseError,dT,sConfig.design.pll);
    sFLL = fctLoopFLL(dFrequencyError,dT,sConfig.design.fll);
    
    % Lecture forward-Euler form: all right-hand states belong to epoch k.
    sNext = sState;
    sNext.dTime = sState.dTime + dT;
    sNext.dCarrierPhase = sState.dCarrierPhase + sState.dDoppler * dT + sPLL.dPhase;
    sNext.dDoppler = sState.dDoppler + sState.dDopplerRate * dT + sPLL.dDoppler + sFLL.dDoppler;
    sNext.dDopplerRate = sState.dDopplerRate + sPLL.dDopplerRate + sFLL.dDopplerRate;
    sNext.dCodeDelay = fctLoopDLL(sState.dCodeDelay,dCodeError,sState.dDoppler,dT,sConfig.design.dll);
    sNext.vPreviousIF = vReceived;

    sOutput.vCorrelator = vZ;
    sOutput.dCodeError = dCodeError;
    sOutput.dPhaseError = dPhaseError;
    sOutput.dFrequencyError = dFrequencyError;
    sOutput.bFllValid = bFllValid;
end
