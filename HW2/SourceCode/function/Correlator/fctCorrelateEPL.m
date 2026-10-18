function mZ = fctCorrelateEPL(vReceived, iPRN, dDelay, dPhase, dDoppler, dSpacing, sConfig)
    %% Two adjacent integration epochs
    %% Row: epoch, Column: Early/Prompt/Late
    %% Real IF mixing gain sqrt(2) gives unit correlation at perfect alignment.
    
    if nargin < 7
        sConfig.signal = struct('sampleRate_Hz', 5.714e6, 'intermediateFrequency_Hz', 4.3e6);
        sConfig.tracking.integrationTime_ms = 1;
    end
    
    dIntTime = sConfig.tracking.integrationTime_ms;
    dN = round(sConfig.signal.sampleRate_Hz * dIntTime * 1e-3);
    assert(numel(vReceived) == 2 * dN, 'Input must contain two integration epochs.');
    
    mZ = zeros(2, 3);
    for iArm = 1:3
        dArmDelay = dDelay + (iArm - 2) * dSpacing;
        vReplica = fctReplicaGen(iPRN, dArmDelay, dPhase, dDoppler, 2 * dIntTime, sConfig.signal);
        vMixed = sqrt(2) * vReceived(:).' .* conj(vReplica);
        mZ(:, iArm) = [mean(vMixed(1 : dN)); mean(vMixed(dN + 1 : end))];
    end
end
