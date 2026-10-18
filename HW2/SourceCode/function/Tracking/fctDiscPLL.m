function mError = fctDiscPLL(vPrompt)
    %% Outputs [cycle]. First two are amplitude independent; third is not.
    vI = real(vPrompt); vQ = imag(vPrompt);
    mError = [atan2(vQ,vI)/(2*pi), atan(vQ./vI)/(2*pi), ...
              vQ.*sign(vI)/(2*pi)];
end
