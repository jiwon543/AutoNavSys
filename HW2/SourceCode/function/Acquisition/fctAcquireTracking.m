function sAcquisition = fctAcquireTracking(vReceived, sConfig4, sConfig3)
    %% Use HW1 acquisition and detection; no signal truths are used here.
    dFs = sConfig3.signal.sampleRate_Hz;
    iNumSample = round(sConfig4.acquisition.integrationTime_ms * 1e-3 * dFs);
    vIF = double(vReceived(1:iNumSample));
    %% Parallel Acquisition
    sSearch = fctParallelAcq(vIF,1023,sConfig4.acquisition.codeBin_chip, ...
        sConfig4.acquisition.dopplerBin_Hz,sConfig4.acquisition.integrationTime_ms);
    %% Acqusition Result
    tDetection = fctSelection(sSearch,sConfig4.acquisition.falseAlarmProbability);
    assert(~isempty(tDetection),'Acquisition failed: no detected satellite.');
    [~,iSelected] = max(tDetection.Peak ./ tDetection.Threshold);
    iPRN = tDetection.PRN(iSelected);
    dDelay = tDetection.CodeDelay_chip(iSelected);
    dDoppler = tDetection.DopplerShift_Hz(iSelected);

    %% Generate Replica Signal
    vReplica = fctReplicaGen(iPRN,dDelay,0,dDoppler, ...
        sConfig4.acquisition.integrationTime_ms,sConfig3.signal);
    dPhase = angle(mean(vIF .* conj(vReplica))) / (2*pi);
    dStartTime = iNumSample / dFs;
    sState = fctInitTracking(iPRN, ...
        dDelay-sConfig3.design.dll.carrierToCodeScale*dDoppler*dStartTime, ...
        dPhase+dDoppler*dStartTime,dDoppler,0);
    sState.dTime = dStartTime;
    
    %% Result of Acquisition
    sAcquisition.tDetection = tDetection;
    sAcquisition.iPRN = iPRN;
    sAcquisition.dCodeDelay_chip = dDelay;
    sAcquisition.dDoppler_Hz = dDoppler;
    sAcquisition.dCarrierPhase_cycle = dPhase;
    sAcquisition.dTrackingStart_s = dStartTime;
    sAcquisition.iNumSample = iNumSample;
    sAcquisition.dSearchTime_s = sSearch.dTime;
    sAcquisition.sInitialState = sState;
    sAcquisition.mPower = squeeze(sSearch.mPower(iPRN,:,:));
    sAcquisition.vCodeSearch = sSearch.vCodeSearch;
    sAcquisition.vDopplerSearch = sSearch.vDoppSearch;
    fprintf('Acquired PRN %d: delay %.3f chip, Doppler %.1f Hz, phase %.5f cycle.\n', ...
        iPRN,dDelay,dDoppler,dPhase);
end
