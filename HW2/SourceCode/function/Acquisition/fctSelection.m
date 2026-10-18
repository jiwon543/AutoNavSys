function tAcqResult = fctSelection(sConvAcq, dPfa)
    %% Acquisition Selection Logic

    if nargin < 2
        dPfa = 0.01;
    end

    %% Parameter
    dNumSV = size(sConvAcq.mPower, 1);

    dNumDelay = size(sConvAcq.mPower, 2);
    dNumDopp = size(sConvAcq.mPower, 3);

    dNumCell = dNumDelay * dNumDopp;

    % Overall Pfa -> Pfa for one search cell
    dPfaCell = 1 - (1 - dPfa)^(1 / dNumCell);

    %% Result
    vPRN = [];
    vCodeDelay = [];
    vDoppler = [];
    vPeak = [];
    vThreshold = [];

    %% Selection
    for iPRN = 1:dNumSV

        mAcq = squeeze(sConvAcq.mPower(iPRN, :, :));

        % Threshold Test
        sThreshold = fctThreshold(mAcq, dPfaCell);

        if sThreshold.bDetected

            [iDelay, iDopp] = ...
                ind2sub(size(mAcq), sThreshold.iPeak);

            vPRN(end+1) = iPRN;

            vCodeDelay(end+1) = ...
                sConvAcq.vCodeSearch(iDelay);

            vDoppler(end+1) = ...
                sConvAcq.vDoppSearch(iDopp);

            vPeak(end+1) = sThreshold.dPeak;
            vThreshold(end+1) = sThreshold.dThreshold;

        end
        
    end
    %% Result Table
    tAcqResult = table( ...
        vPRN.', ...
        vCodeDelay.', ...
        vDoppler.', ...
        vPeak.', ...
        vThreshold.', ...
        'VariableNames', ...
        {'PRN', 'CodeDelay_chip', 'DopplerShift_Hz', ...
         'Peak', 'Threshold'});
    
    if isempty(vPRN)
        fprintf('\n == !! Fail to detect PRN. Check the C/N0 or Integration Time. !! == \n\n')
    end
end