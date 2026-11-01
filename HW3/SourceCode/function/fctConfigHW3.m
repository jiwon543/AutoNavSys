function s = fctConfigHW3(sRoot)
    s.truthFile = fullfile(sRoot, 'Data', 'ChSignalParameterTruth.mat');
    s.resultDir = fullfile(sRoot, 'Result');
    if ~isfolder(s.resultDir)
        mkdir(s.resultDir);
    end
    a = load(s.truthFile, 'ChSignalParameterTruth');
    s.channels = 1:numel(a.ChSignalParameterTruth);
    s.maxEpochs = inf; % Set to e.g. 1000 for a short run.
    s.seed = 300;
    s.noiseStd = 1; % Each real I/Q component has variance 1.
    s.earlyLateOffset_chip = .5; % Arms are separated by 1 chip.
    s.carrierToCodeScale = 1.023e6 / 1575.42e6;
    s.initialError = [.10; .04; 2; 0]; % estimate-truth: chip, cycle, Hz, Hz/s
    s.dll.gain_per_s = 4;

    % Provided HW3 tau increases with positive Doppler, unlike HW2 replica delay.
    s.dll.carrierToCodeScale = -s.carrierToCodeScale;
    s.pll.naturalFrequency_rad_s = 8;
    s.pll.a3 = 1.1;
    s.pll.b3 = 2.4;
    s.fll.naturalFrequency_rad_s = 2;
    s.fll.a2 = sqrt(2);
    s.fllAssist_s = 5; % FLL-assisted PLL pull-in interval.
    s.kf.initialStd = [.2; .1; 5; 2];
    s.kf.codePSD = 1e-5; % chip^2/s, independent code random walk
    s.kf.jerkPSD = .1; % (Hz/s)^2/s, Doppler-rate random walk
    s.cn0Window_s = 1;
    s.statisticsStart_s = 5;
    s.figureVisible = 'off'; % PNG and FIG are saved regardless.
end
