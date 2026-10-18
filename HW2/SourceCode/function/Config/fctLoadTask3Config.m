function sConfig = fctLoadTask3Config(sFile)
    sConfig = jsondecode(fileread(sFile));
    dT = sConfig.assumptions.integrationTime_ms * 1e-3;
    dSamples = sConfig.signal.sampleRate_Hz * dT;
    assert(dT > 0 && abs(dSamples-round(dSamples)) < 1e-8, 'Invalid integration sample count.');
    assert(sConfig.tracking.earlyLateOffset_chip == 0.5,'DLL normalization needs 0.5 chip arm offset.');
    validateattributes(sConfig.tracking.pllDiscriminatorColumn,{'numeric'},{'scalar','integer','>=',1,'<=',3});
    validateattributes(sConfig.tracking.fllDiscriminatorColumn,{'numeric'},{'scalar','integer','>=',1,'<=',3});
    assert(abs(sConfig.design.pll.naturalFrequency_rad_s-1.2*sConfig.design.pll.bandwidth_Hz)<1e-9);
    assert(abs(sConfig.design.fll.naturalFrequency_rad_s-1.89*sConfig.design.fll.bandwidth_Hz)<1e-9);
    assert(abs(sConfig.design.dll.gain_per_s-4*sConfig.design.dll.bandwidth_Hz)<1e-9);
end
