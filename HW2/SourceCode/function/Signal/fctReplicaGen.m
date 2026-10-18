function vReplica = fctReplicaGen(iPRN, dCodeDelay, dCarrierPhase, dDoppler, dIntTime, sSignal)
    %% Generate local replica signals

    % dIntTime [ms], dCodeDelay [chip], dCarrierPhase [cycle], dDoppler [Hz]
    if nargin < 5, dIntTime = 1; end

    if nargin < 6
        sSignal = struct('sampleRate_Hz',5.714e6,'intermediateFrequency_Hz',4.3e6);
    end
    dTs = 1 / sSignal.sampleRate_Hz; % Sampling period [s]
    dNumSample = round(dIntTime * 1e-3 / dTs);
    vTk = (0 : dNumSample - 1) * dTs;
    dfIF = sSignal.intermediateFrequency_Hz;  % [Hz]

    vCode = fctCA(iPRN);
    vSampledCode = fctShiftSampledCA(vCode, dTs, dCodeDelay, dNumSample);

    vCarrier = exp(1j * 2 * pi * ((dfIF + dDoppler) * vTk + dCarrierPhase));

    vReplica = vSampledCode(:).' .* vCarrier;
end