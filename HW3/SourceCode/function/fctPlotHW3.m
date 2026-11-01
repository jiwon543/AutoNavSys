function fctPlotHW3(c, a, b, s)
    labels = {'Code delay [chip]', 'Carrier phase [cycle]', 'Doppler [Hz]', ...
              'Doppler rate [Hz/s]', 'C/N0 [dB-Hz]'};
    mode = 'Task1';
    if ~isempty(b)
        mode = 'Task2';
    end
    suffix = sprintf('%s_PRN%02d', mode, c.SVID);
    h = figure('Visible', s.figureVisible, 'Position', [50 50 1250 1150]);
    tiledlayout(5, 2, 'TileSpacing', 'compact');
    for j = 1:5
        if j < 5
            v = a.truth(j, :);
            va = a.estimate(j, :);
            if ~isempty(b)
                vb = b.estimate(j, :);
            end
        else
            v = reshape(c.CNo(1:numel(a.t)), 1, []);
            va = a.cn0;
            if ~isempty(b)
                vb = b.cn0;
            end
        end
        nexttile;
        plot(a.t, v, 'k', 'DisplayName', 'Truth');
        hold on;
        plot(a.t, va, 'b', 'DisplayName', 'DLL/PLL/FLL');
        if ~isempty(b)
            plot(b.t, vb, 'r', 'DisplayName', 'Error-state KF');
        end
        grid on;
        ylabel(labels{j});
        legend('Location', 'best');
        if j == 1
            title(sprintf('PRN %d estimates', c.SVID));
        end
        nexttile;
        plot(a.t, va - v, 'b', 'DisplayName', 'DLL/PLL/FLL');
        hold on;
        if ~isempty(b)
            plot(b.t, vb - v, 'r', 'DisplayName', 'Error-state KF');
        end
        grid on;
        ylabel(['Error: ' labels{j}]);
        if j == 1
            title('Estimate - truth (unwrapped phase)');
        end
        if j == 5
            xlabel('Elapsed time [s]');
        end
    end
    fctSaveFigure(h, s.resultDir, [suffix '_Estimates']);
    h = figure('Visible', s.figureVisible, 'Position', [100 100 1150 780]);
    tiledlayout(3, 1);
    dl = {'DLL [chip]', 'PLL [cycle]', 'FLL [Hz]'};
    for j = 1:3
        nexttile;
        plot(a.t, a.discriminator(j, :), 'b');
        hold on;
        if ~isempty(b)
            plot(b.t, b.discriminator(j, :), 'r');
        end
        grid on;
        ylabel(dl{j});
        if j == 1
            title(sprintf('PRN %d discriminator outputs (truth - estimate)', c.SVID));
            if isempty(b)
                legend('DLL/PLL/FLL');
            else
                legend('DLL/PLL/FLL', 'Error-state KF');
            end
        end
    end
    xlabel('Elapsed time [s]');
    fctSaveFigure(h, s.resultDir, [suffix '_Discriminators']);
end
