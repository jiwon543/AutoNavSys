function mError = fctDiscFLL(vPrompt1, vPrompt2, dT)
    %% Outputs [Hz]. Epoch spacing dT is in seconds.
    
    vProduct = conj(vPrompt1) .* vPrompt2;
    vCross = imag(vProduct); 
    vDot = real(vProduct);
    vAmplitude = abs(vPrompt1) .* abs(vPrompt2);
    mError = [vCross ./ max(vAmplitude, eps), ...
              vCross .* sign(vDot) ./ max(vAmplitude, eps), ...
              atan2(vCross, vDot)] / (2 * pi * dT);
    
    % No meaningful phase/frequency at a coherent integration null.
    mError(vAmplitude < 1e-6,:) = NaN;
end
