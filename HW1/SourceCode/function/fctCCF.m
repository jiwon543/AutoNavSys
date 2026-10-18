function sCCF = fctCCF(vCode1, vCode2)
    %% Cross Correlation Function
    %% Circular Cross-Correlation (normalized)
    vCode1 = double(vCode1(:)).';
    vCode2 = double(vCode2(:)).';
    dN = length(vCode1);
    vR = real(ifft(fft(vCode1) .* conj(fft(vCode2)))) / dN;
    sCCF.vCCF = fftshift(vR);
    sCCF.vLag = -floor(dN/2) : ceil(dN/2)-1;
end