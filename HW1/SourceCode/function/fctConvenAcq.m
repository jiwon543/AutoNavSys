function sConvAcq = fctConvenAcq(vIF, dCodeLength, dCodeBin, dDoppBin)
    %% Conventional Acquisition Method (Time-Frequency Search)

    if nargin < 2
        dCodeLength = 1023;
    end

    if nargin < 3
        dCodeBin = 0.5; % [chip]
    end

    if nargin < 4
        dDoppBin = 250; % [Hz]
    end

    %% Parameter Definition
    vIF = double(vIF(:).');

    dTs = 1 / (5.714e6); % [sec/sample]
    dfIF = 4.3e6;        % [Hz]

    dL = length(vIF);
    vt = (0:dL-1) * dTs;

    %% Code Delay Search
    dCodeArea = dCodeLength;

    vCodeSearch = 0:dCodeBin:dCodeArea;
    vCodeSearch(vCodeSearch >= dCodeArea) = [];

    dNumDelay = length(vCodeSearch);

    %% Doppler Search
    dDoppArea = 10e3; % [Hz]

    vDoppSearch = -dDoppArea:dDoppBin:dDoppArea;
    dNumDopp = length(vDoppSearch);

    %% SV Search
    dNumSV = 32;

    mPower = zeros(dNumSV, dNumDelay, dNumDopp);

    %% Conventional Acquisition
    tic;

    for iSV = 1:dNumSV
        fprintf('PRN %d\n', iSV);

        % Generate C/A code for current PRN
        vCode = fctCA(iSV);

        for iDelay = 1:dNumDelay
            dCodeSearch = vCodeSearch(iDelay);

            % Apply code delay and sampling
            vCodeDelayed = fctShiftSampledCA(vCode, dTs, dCodeSearch, dL);

            for iDopp = 1:dNumDopp
                dDoppSearch = vDoppSearch(iDopp);

                vIcarrier = cos(2*pi*(dfIF + dDoppSearch)*vt);
                vQcarrier = sin(2*pi*(dfIF + dDoppSearch)*vt);

                vImix = vIF .* vIcarrier;
                vQmix = vIF .* vQcarrier;

                vIsig = vImix .* vCodeDelayed';
                vQsig = vQmix .* vCodeDelayed';

                dIcorr = sum(vIsig);
                dQcorr = sum(vQsig);

                mPower(iSV, iDelay, iDopp) = dIcorr.^2 + dQcorr.^2;
            end
        end
    end

    dTime = toc;

    fprintf('Conventional Acquisition Total execution time: %.2f seconds\n', ...
        dTime);

    %% Output
    sConvAcq.mPower = mPower;
    sConvAcq.vCodeSearch = vCodeSearch;
    sConvAcq.vDoppSearch = vDoppSearch;
    sConvAcq.dTime = dTime;
end