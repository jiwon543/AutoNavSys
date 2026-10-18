function vShiftedSampleCode = fctShiftSampledCA(vCode, dTs, dCodeDelay, dNumSample)

    %% Generate Sampled C/A Code with Code Delay

    if nargin < 2
        dTs = 1 / (5.714e6);    % [sec/sample]
    end

    if nargin < 3
        dCodeDelay = 0;         % [chip]
    end

    if nargin < 4
        dNumSample = round(1e-3 / dTs);
    end

    %% Parameter Definition
    dCodeLength = length(vCode);
    dTc = 1e-3 / dCodeLength;   % [sec/chip]

    vt = (0:dNumSample-1) * dTs;

    %% Code Phase
    vChipPhase = vt / dTc - dCodeDelay;

    %% Chip Index
    vChipIdx = mod(floor(vChipPhase), dCodeLength) + 1;

    %% Sampling
    vShiftedSampleCode = vCode(vChipIdx);

end