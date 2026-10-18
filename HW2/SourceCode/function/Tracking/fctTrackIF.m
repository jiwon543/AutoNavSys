function sTracking = fctTrackIF(vReceived, sAcquisition, sConfig3)
    %% Process the recorded IF after the acquisition interval.
    dT = sConfig3.assumptions.integrationTime_ms * 1e-3;
    iBlockSize = round(sConfig3.signal.sampleRate_Hz * dT);
    iFirstSample = sAcquisition.iNumSample + 1;
    iNumEpoch = floor((numel(vReceived)-iFirstSample + 1) / iBlockSize);
    assert(iNumEpoch > 0,'No IF samples remain after acquisition.');
    sState = sAcquisition.sInitialState;
    mHistory = zeros(iNumEpoch,21);
    for iEpoch = 1 : iNumEpoch
        iStart = iFirstSample + (iEpoch - 1) * iBlockSize;
        % Sample index defines absolute time without accumulated clock roundoff.
        sState.dTime = (iStart - 1) / sConfig3.signal.sampleRate_Hz;
        %% Tracking per each epoch(step)
        vIF = double(vReceived(iStart : iStart + iBlockSize - 1));
        [sNext, sOutput] = fctTrackingStep(vIF, sState, sConfig3);
        %% ===== ===== ===== ===== =====
        dMidIncrement = sState.dDoppler * dT / 2 + sState.dDopplerRate * dT^2 / 8;
        vZ = sOutput.vCorrelator;
        mHistory(iEpoch, :) = [sState.dTime + dT / 2, ...
            real(vZ(1)),imag(vZ(1)),real(vZ(2)),imag(vZ(2)),real(vZ(3)),imag(vZ(3)), ...
            abs(vZ).^2,sOutput.dCodeError,sOutput.dPhaseError,sOutput.dFrequencyError, ...
            sOutput.bFllValid, sState.dCarrierPhase, sState.dDoppler, sState.dDopplerRate, sState.dCodeDelay, ...
            sState.dCarrierPhase + dMidIncrement, sState.dDoppler + sState.dDopplerRate * dT / 2, ...
            sState.dCodeDelay - sConfig3.design.dll.carrierToCodeScale * dMidIncrement];
        sState = sNext;
    end
    cColumn = {'Time_s','IE','QE','IP','QP','IL','QL','EarlyPower','PromptPower','LatePower', ...
        'DLL_chip','PLL_cycle','FLL_Hz','FllValid','Phase_cycle','Doppler_Hz','DopplerRate_Hz_s', ...
        'Delay_chip','PhaseMid_cycle','DopplerMid_Hz','DelayMid_chip'};
    sTracking.tHistory = array2table(mHistory,'VariableNames',cColumn);
    sTracking.sFinalState = rmfield(sState,{'vCode','vPreviousIF'});
end
