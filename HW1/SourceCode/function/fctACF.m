function sACF = fctACF(vCode)
    %% Autocorrelation Function
    % Note: 입력 인수의 행렬 유의; N-by-1 [O], 1-by-N [X] (e.g., Sampled & Shifted Code)
    %% Circular Auto-Correlation (normalized)
    vCode = double(vCode(:)).';
    dN = length(vCode);
    vR = real(ifft(fft(vCode) .* conj(fft(vCode)))) / dN;
    sACF.vACF = fftshift(vR);
    sACF.vLag = -floor(dN/2) : ceil(dN/2)-1;
end