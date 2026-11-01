function fctSummaryHW3(cLoop, cKF, s)
    rows = cell(0, 8);
    for j = 1:numel(cLoop)
        for c = {cLoop{j}, cKF{j}}
            a = c{1};
            keep = a.t >= s.statisticsStart_s;
            assert(any(keep), 'Run longer than statisticsStart_s.');
            e = sqrt(mean(a.error(:, keep) .^ 2, 2));
            cn = a.cn0(keep);
            cn = cn(isfinite(cn));
            rows(end + 1, :) = {a.SVID, a.method, e(1), e(2), e(3), e(4), ...
                                mean(cn), sum(abs(a.error(2, keep)) > .5)}; %#ok<AGROW>
        end
    end
    t = cell2table(rows, 'VariableNames', {'PRN', 'Method', 'CodeRMSE_chip', ...
                                           'PhaseRMSE_cycle', 'DopplerRMSE_Hz', 'RateRMSE_Hz_s', ...
                                           'MeanCN0_dBHz', 'PhaseErrorOverHalfCycle_epochs'});
    disp(t);
    writetable(t, fullfile(s.resultDir, 'TrackingSummary.csv'));
end
