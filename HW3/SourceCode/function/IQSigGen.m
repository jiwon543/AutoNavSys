function[Ip, Qp, Ie, Qe, Il, Ql] = IQSigGen(SN, dtau, dphi, df, PIT, dOffset, dNoiseStd)
    % SN = linear C/N0 [1/s], NOT dB-Hz and NOT integrated SNR.
    % Errors = truth-estimate. Phase is referenced to integration midpoint.
    % Homework amplitude: 2*sqrt(SN*PIT); independent real I/Q noise var=1.
    if nargin < 6
        dOffset = .5;
    end
    if nargin < 7
        dNoiseStd = 1;
    end
    assert(all(SN(:) >= 0) && PIT > 0, 'Invalid C/N0 or integration time.');
    u = df .* PIT;
    a = ones(size(u));
    b = abs(u) > eps;
    a(b) = sin(pi * u(b)) ./ (pi * u(b)); % normalized sinc; no toolbox required
    z = 2 * sqrt(SN .* PIT) .* a .* exp(1j * 2 * pi * dphi);
    p = z .* CorrFunc(dtau);
    e = z .* CorrFunc(dtau + dOffset);
    l = z .* CorrFunc(dtau - dOffset);
    p = p + dNoiseStd * (randn(size(p)) + 1j * randn(size(p)));
    e = e + dNoiseStd * (randn(size(e)) + 1j * randn(size(e)));
    l = l + dNoiseStd * (randn(size(l)) + 1j * randn(size(l)));
    Ip = real(p);
    Qp = imag(p);
    Ie = real(e);
    Qe = imag(e);
    Il = real(l);
    Ql = imag(l);
end
