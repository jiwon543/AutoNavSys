function o = fctRunBaseband(c, s, method)
    % State: [code delay chip; carrier phase cycle; Doppler Hz; rate Hz/s].
    % Truth is used ONLY by the simulated signal source and initialization.
    % The receiver sees I/Q, configuration and its own previous estimates.
    rng(s.seed + double(c.SVID), 'twister'); % Common noise for both methods.
    n = min(numel(c.tau), s.maxEpochs);
    T = c.dt;
    truth = [reshape(c.tau(1:n), 1, []); ...
             reshape(c.phi(1:n), 1, []); ...
             reshape(c.f(1:n), 1, []); ...
             reshape(c.f_rate(1:n), 1, [])];
    x = truth(:, 1) + s.initialError;
    P = diag(s.kf.initialStd .^ 2);
    r = s.carrierToCodeScale;
    F = [1 0 r * T r * T ^ 2 / 2; ...
         0 1 T     T ^ 2 / 2; ...
         0 0 1     T; ...
         0 0 0     1];

    % Exact integrated white Doppler jerk covariance; code is carrier aided.
    Q = s.kf.jerkPSD * [r ^ 2 * T ^ 5 / 20 r * T ^ 5 / 20 r * T ^ 4 / 8 r * T ^ 3 / 6; ...
                        r * T ^ 5 / 20 T ^ 5 / 20 T ^ 4 / 8 T ^ 3 / 6; ...
                        r * T ^ 4 / 8 T ^ 4 / 8 T ^ 3 / 3 T ^ 2 / 2; ...
                        r * T ^ 3 / 6 T ^ 3 / 6 T ^ 2 / 2 T];
    Q(1, 1) = Q(1, 1) + s.kf.codePSD * T;
    o.method = method;
    o.SVID = c.SVID;
    o.T = T;
    o.t = (0:n - 1) * T;
    o.startTime = c.start_time;
    o.truth = truth;
    o.estimate = zeros(4, n);
    o.discriminator = nan(3, n);
    o.prompt = complex(zeros(1, n));
    o.prior = zeros(4, n);
    o.cn0 = nan(1, n);
    o.sigma = zeros(4, n);
    w = max(10, round(s.cn0Window_s / T));
    previousPrompt = [];
    previousPhase = 0;
    for k = 1:n
        prior = x;
        err = truth(:, k) - prior;
        [ip, qp, ie, qe, il, ql] = IQSigGen(10 ^ (c.CNo(k) / 10), err(1), err(2), err(3), ...
            T, s.earlyLateOffset_chip, s.noiseStd);
        z = [complex(ie, qe), complex(ip, qp), complex(il, ql)];
        dll = fctDiscDLL(z);
        pll = fctDiscPLL(z(2));

        % HW2 DLL output is estimate-truth; convert to truth-estimate.
        y = [-dll(1); pll(1)];
        fError = NaN;
        if ~isempty(previousPrompt)
            % Re-reference previous correlator to a continuous current NCO.
            % Prevent PLL phase injection from being interpreted as Doppler.
            shift = prior(2) - prior(3) * T + prior(4) * T ^ 2 / 2 - previousPhase;
            prev = previousPrompt * exp(-1j * 2 * pi * shift);
            fll = fctDiscFLL(prev, z(2), T);
            fError = fll(3) + prior(4) * T / 2;
        end
        o.prior(:, k) = prior;
        o.prompt(k) = z(2);
        o.discriminator(:, k) = [y; fError];
        previousPrompt = z(2);
        previousPhase = prior(2);
        %% Kalman Filter (; Method)
        if strcmp(method, 'KF')
            % Linear error-state update; FLL shares phase noise and is NOT
            % added as an independent observation. DLL/PLL observe errors.
            H = [1 0 0 0; ...
                 0 1 0 0];

            % Estimate signal amplitude from receiver prompt power, not truth C/N0.
            first = max(1, k - w + 1);
            power = mean(abs(o.prompt(first:k)) .^ 2);
            a2 = max(power - 2, 4);
            R = diag([1 / (2 * a2), 1 / (4 * pi ^ 2 * a2)]);
            [x, P] = fctErrorStateKF(prior, P, y, H, R);
            o.estimate(:, k) = x;
            o.sigma(:, k) = sqrt(max(diag(P), 0));
            x = F * x;
            P = F * P * F' + Q;
        else
            p = fctLoopPLL(y(2), T, s.pll);
            ff = struct('dDoppler', 0, 'dDopplerRate', 0);
            if isfinite(fError) && o.t(k) < s.fllAssist_s
                ff = fctLoopFLL(fError, T, s.fll);
            end

            % forward-Euler feedback: same pre-update state on RHS
            x = prior;
            x(1) = fctLoopDLL(prior(1), dll(1), prior(3), T, s.dll);
            x(2) = prior(2) + prior(3) * T + p.dPhase;
            x(3) = prior(3) + prior(4) * T + p.dDoppler + ff.dDoppler;
            x(4) = prior(4) + p.dDopplerRate + ff.dDopplerRate;

            % Save estimate at the measurement epoch, not at epoch k+1.
            o.estimate(:, k) = prior + [s.dll.gain_per_s * T * y(1); ...
                                        p.dPhase; ...
                                        p.dDoppler + ff.dDoppler; ...
                                        p.dDopplerRate + ff.dDopplerRate];
        end
        if k >= w
            % Noncentral complex-Gaussian moment estimator, unit noise model.
            v = abs(o.prompt(k - w + 1:k)) .^ 2;
            m2 = mean(v);
            m4 = mean(v .^ 2);
            signalPower = sqrt(max(2 * m2 ^ 2 - m4, 0));
            noisePower = max(m2 - signalPower, eps);

            % A^2=4*(C/N0)*T; E|noise|^2=2*sigma^2.
            o.cn0(k) = 10 * log10(max(signalPower / (2 * T * noisePower), eps));
        end
    end
    o.error = o.estimate - truth; % Unwrapped phase: cycle slips remain visible.
    fprintf('%s PRN %d: %d epochs, %.2f s\n', method, c.SVID, n, o.t(end));
end
