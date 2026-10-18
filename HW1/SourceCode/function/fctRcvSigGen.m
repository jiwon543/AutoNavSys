function vReceivedSignal = fctRcvSigGen(iPRN, dCodeDelay, dInitCarrierPhase, dDoppler, dCN0, dIntTime)
    %% GPS L1 C/A Signal Simulator

    if nargin < 6
        dIntTime = 1; % [ms]
    end

    %% Parameter Definition
    dFs = 5.714e6;      % [Hz]
    dTs = 1 / dFs;      % [sec/sample]
    dfIF = 4.3e6;       % [Hz]

    dDuration = dIntTime * 1e-3; % [sec]
    dL = round(dDuration * dFs);

    vt = (0:dL-1) * dTs;

    %% Signal Power
    dP = 1;

    %% C/A Code
    vCode = fctCA(iPRN);

    vSampledCode = fctShiftSampledCA(vCode, dTs, dCodeDelay, dL);

    vSampledCode = vSampledCode(:).';

    %% Carrier
    dPhase = 2*pi*dInitCarrierPhase;

    vCarrier = cos(2*pi*(dfIF + dDoppler)*vt + dPhase);

    %% GPS Signal
    vSignal = sqrt(2*dP) .* vSampledCode .* vCarrier;

    %% C/N0
    dCN0 = 10^(dCN0 / 10);

    dN0 = dP / dCN0;
    dNoiseStd = sqrt(dN0 * dFs / 2);

    %% AWGN
    vNoise = fctAWGN(0, dNoiseStd, dL);

    %% Received Signal
    vReceivedSignal = vSignal + vNoise;

end