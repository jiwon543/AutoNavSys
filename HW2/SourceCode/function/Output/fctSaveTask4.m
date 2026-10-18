function fctSaveTask4(sTask4,sConfig4,sConfig3,sOut)
    %% Store estimates, acquisition detections and summary statistics.
    save(fullfile(sOut,'Task4.mat'),'sTask4','sConfig4','sConfig3','-v7.3');
    writetable(sTask4.sAcquisition.tDetection,fullfile(sOut,'Acquisition.csv'));
    writetable(sTask4.sTracking.tHistory,fullfile(sOut,'Tracking.csv'));
    sSummary = sTask4.sTracking.sSummary;
    iFile = fopen(fullfile(sOut,'Summary.json'),'w','n','UTF-8');
    assert(iFile>=0,'Cannot write tracking summary.');
    oCleanup = onCleanup(@() fclose(iFile));
    fprintf(iFile,'%s\n',jsonencode(sSummary,'PrettyPrint',true));
    fprintf('Tracking complete: %d epochs; phase RMS %.3f deg; Doppler RMS %.3f Hz; code RMS %.6f chip.\n', ...
        sSummary.iNumEpoch,sSummary.dPhaseRms_deg,sSummary.dDopplerRms_Hz,sSummary.dCodeRms_chip);
end
