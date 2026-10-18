function sThreshold = fctThreshold(mAcq, dPfa)
    %% Acquisition Threshold

    if nargin < 2
        dPfa = 0.01;
    end

    %% Estimate H0 Noise Power
    dNoisePower = median(mAcq(:)) / log(2);

    %% Threshold
    dK = -log(dPfa);
    dThreshold = dK * dNoisePower;

    %% Peak
    [dPeak, iPeak] = max(mAcq(:));

    %% Hypothesis Test
    bDetected = dPeak >= dThreshold;

    %% Result
    sThreshold.dPfa = dPfa;
    sThreshold.dK = dK;
    sThreshold.dNoisePower = dNoisePower;
    sThreshold.dThreshold = dThreshold;
    sThreshold.dPeak = dPeak;
    sThreshold.iPeak = iPeak;
    sThreshold.bDetected = bDetected;
end