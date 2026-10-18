function sConfig = fctLoadTask2Config(sFile)
    sConfig = jsondecode(fileread(sFile));
    validateattributes(sConfig.integrationTime_ms,{'numeric'},{'scalar','positive','finite'});
    validateattributes(sConfig.amplitudes,{'numeric'},{'vector','positive','finite'});
    validateattributes(sConfig.monteCarlo.trials,{'numeric'},{'scalar','integer','>=',2});
    validateattributes(sConfig.monteCarlo.cn0_dBHz,{'numeric'},{'vector','finite'});
    assert(abs(sConfig.monteCarlo.codeError_chip)<.5,'DLL Monte Carlo truth must lie within +/-0.5 chip.');
    assert(abs(sConfig.monteCarlo.frequencyError_Hz)<1/(4*sConfig.integrationTime_ms*1e-3), ...
        'Choose an FLL Monte Carlo truth within the cross-sign unambiguous range.');
    for cName = {'phaseDifference_rad','codeError_chip'}
        sRange = sConfig.(cName{1});
        validateattributes(sRange.step,{'numeric'},{'scalar','positive','finite'});
        validateattributes(sRange.start,{'numeric'},{'scalar','finite'});
        validateattributes(sRange.stop,{'numeric'},{'scalar','finite','>=',sRange.start});
    end
    assert(sConfig.codeError_chip.start>-.5 && sConfig.codeError_chip.stop<.5, ...
        'DLL derivation uses the central linear interval.');
end
