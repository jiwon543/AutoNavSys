function[x, P] = fctErrorStateKF(x, P, y, H, R)
    % Option II: linear measurement of truth-minus-nominal error.
    % Error prior mean is zero after each injection into the nominal state.
    K = (P * H') / (H * P * H' + R);
    dx = K * y;
    x = x + dx;
    J = eye(numel(x)) - K * H;
    P = J * P * J' + K * R * K';
    P = (P + P') / 2;
end
