function dNextDelay = fctLoopDLL(dDelay, dCodeError, dDoppler, dT, sDLL)
    %% First-order DLL with internal carrier Doppler aiding [chip].
    % DLL discriminator gives estimate - truth: subtract its correction.
    % Positive Doppler advances C(t-delay): delay decreases.
    dNextDelay = dDelay - sDLL.gain_per_s * dT * dCodeError ...
        - sDLL.carrierToCodeScale * dDoppler * dT;
end
