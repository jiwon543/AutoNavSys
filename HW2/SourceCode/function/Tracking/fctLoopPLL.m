function sCorrection = fctLoopPLL(dPhaseError, dT, sPLL)
    %% Third-order PLL correction; input phase error [cycle].
    % Corrections are combined with FLL before advancing the shared state.
    dW0 = sPLL.naturalFrequency_rad_s;
    sCorrection.dPhase = sPLL.b3 * dW0 * dT * dPhaseError;
    sCorrection.dDoppler = sPLL.a3 * dW0^2 * dT * dPhaseError;
    sCorrection.dDopplerRate = dW0^3 * dT * dPhaseError;
end
