function sCorrection = fctLoopFLL(dFrequencyError, dT, sFLL)
    %% Second-order FLL correction; input residual frequency [Hz].
    dW0 = sFLL.naturalFrequency_rad_s;
    sCorrection.dDoppler = sFLL.a2 * dW0 * dT * dFrequencyError;
    sCorrection.dDopplerRate = dW0^2 * dT * dFrequencyError;
end
