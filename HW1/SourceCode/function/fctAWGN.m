function vNoise = fctAWGN(dMean, dStd, dNum)
    %% Additive White Gaussian Noise
    vNoise = dMean + dStd * randn(1, dNum);
end