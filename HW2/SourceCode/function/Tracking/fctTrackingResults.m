function sTracking = fctTrackingResults(sTracking, sSignalTruth, sConfig4)
    %% Truth is used only AFTER tracking to report estimation errors.
    tHistory = sTracking.tHistory;
    vTime = tHistory.Time_s;
    tHistory.NavigationBit = interp1(sSignalTruth.vTime_s, sSignalTruth.vNavigationBit, vTime, 'previous');
    tHistory.TruePhase_cycle = interp1(sSignalTruth.vTime_s, sSignalTruth.vCarrierPhase_cycle, vTime,'spline');
    tHistory.TrueDoppler_Hz = interp1(sSignalTruth.vTime_s, sSignalTruth.vDoppler_Hz,vTime, 'spline');
    tHistory.TrueDelay_chip = interp1(sSignalTruth.vTime_s, sSignalTruth.vCodeDelay_chip, vTime, 'spline');
    tHistory.PhaseError_cycle = tHistory.TruePhase_cycle-tHistory.PhaseMid_cycle;
    tHistory.DopplerError_Hz = tHistory.DopplerMid_Hz-tHistory.TrueDoppler_Hz;
    tHistory.CodeError_chip = tHistory.DelayMid_chip-tHistory.TrueDelay_chip;
    vInterval = vTime >= sConfig4.tracking.summaryStart_s;
    assert(any(vInterval),'Summary interval contains no tracking samples.');
    sSummary.dIntervalStart_s = vTime(find(vInterval,1));
    sSummary.dIntervalEnd_s = vTime(end);
    sSummary.dPhaseRms_deg = 360 * sqrt(mean(tHistory.PhaseError_cycle(vInterval).^2));
    sSummary.dPhaseBias_deg = 360 * mean(tHistory.PhaseError_cycle(vInterval));
    sSummary.dPhaseStd_deg = 360 * std(tHistory.PhaseError_cycle(vInterval));
    sSummary.dMaxPhaseError_deg = 360 * max(abs(tHistory.PhaseError_cycle(vInterval)));
    sSummary.dDopplerRms_Hz = sqrt(mean(tHistory.DopplerError_Hz(vInterval).^2));
    sSummary.dCodeRms_chip = sqrt(mean(tHistory.CodeError_chip(vInterval).^2));
    sSummary.iNumEpoch = height(tHistory);
    sSummary.iNumInvalidFll = sum(~logical(tHistory.FllValid));
    sTracking.tHistory = tHistory;
    sTracking.sSummary = sSummary;
end
