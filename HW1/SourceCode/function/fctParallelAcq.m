function sParAcq = fctParallelAcq(vIF, dCodeLength, dCodeBin, dDoppBin, dIntTime)
    %% FFT-IFFT Acquisition Method

    if nargin < 2
        dCodeLength = 1023;
    end

    if nargin < 3
        dCodeBin = 0.5; % [chip]
    end

    if nargin < 4
        dDoppBin = 250; % [Hz]
    end

    if nargin < 5
        dIntTime = 1; % [ms]
    end

    %% Parameter Definition
    vIF = double(vIF(:).');
    dFs = 5.714e6; % [Hz]
    dfIF = 4.3e6;  % [Hz]
    dSamplesPerMs = round(dFs * 1e-3);
    dNumInt = round(dIntTime);
    dL = dSamplesPerMs * dNumInt;

    % Use only requested integration interval
    vIF = vIF(1:dL);

    %% Code Delay Search
    [dLagStep, dBinsPerChip] = rat(dCodeBin);
    dNumPhase = dCodeLength * dBinsPerChip;
    vLagSearch = 0:dLagStep:dNumPhase-1;
    vCodeSearch = vLagSearch / dBinsPerChip;
    dNumDelay = length(vCodeSearch);

    %% Doppler Search
    vDoppSearch = -10e3:dDoppBin:10e3;
    dNumDopp = length(vDoppSearch);

    %% SV Search
    dNumSV = 32;
    mPower = zeros(dNumSV, dNumDelay, dNumDopp);

    %% Sample -> Code Phase Bin
    vPhaseBin = ...
        floor((0:dSamplesPerMs-1) * ...
        dNumPhase / dSamplesPerMs) + 1;

    mBinSum = sparse( ...
        vPhaseBin, ...
        1:dSamplesPerMs, ...
        ones(1,dSamplesPerMs), ...
        dNumPhase, ...
        dSamplesPerMs);

    %% Parallel Acquisition
    tic;

    for iSV = 1:dNumSV
        %% C/A Code
        vCode = fctCA(iSV);
        vPhaseCode = repelem(vCode(:).', dBinsPerChip);
        vCodeFFT = conj(fft(vPhaseCode));

        %% Doppler Search
        for iDopp = 1:dNumDopp
            dDoppSearch = vDoppSearch(iDopp);

            % Complex correlation accumulation
            vRsum = zeros(1, dNumPhase);

            %% Coherent Integration
            for iInt = 1:dNumInt

                iStart = (iInt-1)*dSamplesPerMs + 1;
                iEnd = iInt*dSamplesPerMs;

                vIFblock = vIF(iStart:iEnd);

                % Absolute sample time
                vSampleIdx = (iStart-1):(iEnd-1);
                vt = vSampleIdx / dFs;

                % Carrier wipe-off
                vCarrier = exp(-1j * 2*pi * ...
                    (dfIF + dDoppSearch) * vt);

                vBaseband = vIFblock .* vCarrier;

                % Code-phase binning
                vPhaseSum = ...
                    (mBinSum * vBaseband.').';

                % FFT-IFFT correlation
                vSignalFFT = fft(vPhaseSum);

                vR = ifft(vSignalFFT .* vCodeFFT);

                % Coherent accumulation
                vRsum = vRsum + vR;

            end

            %% Acquisition Power
            mPower(iSV, :, iDopp) = ...
                abs(vRsum(vLagSearch + 1)).^2;

        end
    end

    dTime = toc;

    %% Result
    sParAcq.mPower = mPower;
    sParAcq.vCodeSearch = vCodeSearch;
    sParAcq.vDoppSearch = vDoppSearch;
    sParAcq.dIntTime = dIntTime;
    sParAcq.dTime = dTime;

end