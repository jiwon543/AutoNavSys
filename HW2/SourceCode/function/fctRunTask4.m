function sTask4 = fctRunTask4(sIFData, sConfig4, sConfig3)
    %% Acquisition -> tracking -> result extraction.
    %% sConfig3 : Data/Task3.json -> Tracking Loop Parameters (; Integration Time, Order, BW, Type of Disc., etc.)
    %% sConfig4 : Data/Task4.json -> Tracking Configuration (; C/N0, Acqusition Search Spacing, Figure, etc.)
    %% Validation
    assert(sIFData.sMetadata.dSampleRate_Hz == sConfig3.signal.sampleRate_Hz, ...
        'IF file and tracking sample rates differ.');
    assert(sIFData.sConfig4.signal.intermediateFrequency_Hz == sConfig3.signal.intermediateFrequency_Hz, ...
        'IF file and tracking IF frequencies differ.');
    %% Parallel Acquisition 
    sTask4.sAcquisition = fctAcquireTracking(sIFData.vReceivedSignal, sConfig4, sConfig3);
    %% Tracking (1 ms Integration Time)
    sTask4.sTracking = fctTrackIF(sIFData.vReceivedSignal, sTask4.sAcquisition, sConfig3);
    %% Store(Update) Tracking Result
    sTask4.sTracking = fctTrackingResults(sTask4.sTracking, sIFData.sSignalTruth, sConfig4);
    %% sSignalMetadata : IF signal info. (;Num. of Samples, Signal Length, Sampling Freq., etc.)
    sTask4.sSignalMetadata = sIFData.sMetadata;
    %% sGenerationConfig : IF signal config. (; PRN, CodeDelay, Doppler, Carrier Phase, C/N0, etc.)
    sTask4.sGenerationConfig = sIFData.sConfig4;
end
