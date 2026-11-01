function R = CorrFunc(CodeErr)
    % Normalized, ideal BPSK(1) triangular code correlation.
    R = max(1 - abs(CodeErr), 0);
end
