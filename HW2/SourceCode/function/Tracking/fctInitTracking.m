function sState = fctInitTracking(iPRN, dDelay, dPhase, dDoppler, dDopplerRate)
    %% NCO state at the START of the next IF block.
    sState.iPRN = iPRN;
    sState.dTime = 0;                   % [s]
    sState.dCodeDelay = dDelay;         % [chip], delay at block start
    sState.dCarrierPhase = dPhase;      % [cycle], Doppler phase only, excludes IF
    sState.dDoppler = dDoppler;         % [Hz]
    sState.dDopplerRate = dDopplerRate; % [Hz/s]
    sState.vCode = fctCA(iPRN).';
    sState.vPreviousIF = [];
end
