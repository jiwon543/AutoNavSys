function sConfig = fctLoadTask1Config(sFile)
    % JSON names include physical units; output path is relative to HW2 root.
    sConfig = jsondecode(fileread(sFile));
    validateattributes(sConfig.signal.sampleRate_Hz, {'numeric'}, {'scalar','positive','finite'});
    validateattributes(sConfig.signal.intermediateFrequency_Hz, {'numeric'}, {'scalar','nonnegative','finite'});
    validateattributes(sConfig.tracking.integrationTime_ms, {'numeric'}, {'scalar','positive','finite'});
    validateattributes(sConfig.truth.prn, {'numeric'}, {'scalar','integer','>=',1,'<=',32});
    assert(sConfig.tracking.earlyLateOffset_chip == 0.5, ...
        'Current DLL normalization requires an E/P/L offset of 0.5 chip.');
    cFields = fieldnames(sConfig.sweep);
    for i = 1:numel(cFields)
        sRange = sConfig.sweep.(cFields{i});
        validateattributes(sRange.step, {'numeric'}, {'scalar','positive','finite'});
        validateattributes(sRange.start, {'numeric'}, {'scalar','finite'});
        validateattributes(sRange.stop, {'numeric'}, {'scalar','finite','>=',sRange.start});
    end
    dSamples = sConfig.signal.sampleRate_Hz*sConfig.tracking.integrationTime_ms*1e-3;
    assert(abs(dSamples-round(dSamples)) < 1e-8, 'Integration time must span an integer number of samples.');
end
