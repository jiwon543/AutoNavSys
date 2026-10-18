function fctPlotTask2(sTask2,sConfig,sOut)
    %% Plot
    sVisibility = 'off'; if sConfig.output.figureVisible, sVisibility = 'on'; end
    cAmplitudeLabel = arrayfun(@(dAmplitude) sprintf('A = %g',dAmplitude),sTask2.amplitudes,'UniformOutput',false);
    hFigure = figure('Visible',sVisibility,'Position',[100 100 1100 750]);
    tiledlayout(2,1);
    nexttile; plot(sTask2.phaseDifference_rad,sTask2.fllTheory,'LineWidth',sConfig.output.lineWidth); grid on;
    xlabel('Phase difference [rad]'); ylabel('FLL output [Hz]');
    legend('Normalized cross','Cross sign(dot)','atan2(cross,dot)','Location','eastoutside');
    title('FLL identities: I/Q-derived outputs agree with theoretical curves');
    nexttile; plot(sTask2.phaseDifference_rad,sin(sTask2.phaseDifference_rad).*sign(cos(sTask2.phaseDifference_rad)), ...
        sTask2.phaseDifference_rad,sin(2*sTask2.phaseDifference_rad),'--','LineWidth',sConfig.output.lineWidth); grid on;
    xlabel('Phase difference [rad]'); ylabel('Normalized response');
    legend('sin(q) sign(cos(q))','sin(2q)','Location','eastoutside');
    title('Cross sign(dot) is not sin(2q)');
    fctSave(hFigure,'FLL_Derivation',sConfig.output,sOut);

    hFigure = figure('Visible',sVisibility,'Position',[100 100 1100 750]); tiledlayout(2,1);
    nexttile; plot(sTask2.phaseDifference_rad,sTask2.rawCross,'LineWidth',sConfig.output.lineWidth); grid on;
    xlabel('Phase difference [rad]'); ylabel('Raw cross / (2 pi T)'); legend(cAmplitudeLabel,'Location','eastoutside');
    title('Unnormalized cross scales with amplitude squared');
    nexttile; hold on;
    cLineStyle = {'-','--',':'};
    for iAmplitude = 1:numel(sTask2.amplitudes)
        plot(sTask2.phaseDifference_rad,sTask2.fll(:,1,iAmplitude),'LineStyle',cLineStyle{mod(iAmplitude-1,3)+1},'LineWidth',sConfig.output.lineWidth);
    end
    grid on; xlabel('Phase difference [rad]'); ylabel('Normalized cross [Hz]');
    legend(cAmplitudeLabel,'Location','eastoutside'); title('Normalized outputs overlap');
    fctSave(hFigure,'Amplitude_Effect',sConfig.output,sOut);

    hFigure = figure('Visible',sVisibility,'Position',[100 100 1000 500]); hold on;
    plot(sTask2.codeError_chip,sTask2.codeError_chip,'k-','LineWidth',sConfig.output.lineWidth);
    for iAmplitude = 1:numel(sTask2.amplitudes)
        plot(sTask2.codeError_chip,sTask2.dll(:,iAmplitude),'LineStyle',cLineStyle{mod(iAmplitude-1,3)+1},'LineWidth',sConfig.output.lineWidth);
    end
    grid on; xlabel('Estimated delay - true delay [chip]'); ylabel('Envelope DLL output [chip]');
    legend([{'Ideal identity'},cAmplitudeLabel],'Location','eastoutside');
    title('0.5 (E-L)/(E+L) equals code error in the central interval');
    fctSave(hFigure,'DLL_Derivation',sConfig.output,sOut);

    hFigure = figure('Visible',sVisibility,'Position',[100 100 1100 750]); tiledlayout(2,1);
    tNoise = sTask2.tNoise;
    nexttile; semilogy(tNoise.CN0_dBHz,tNoise{:,8:10},'-o','LineWidth',sConfig.output.lineWidth); grid on;
    xlabel('C/N0 [dB-Hz]'); ylabel('FLL RMSE [Hz]');
    legend('Normalized cross','Cross sign(dot)','atan2','Location','eastoutside');
    title(sprintf('Monte Carlo: %d trials, true residual frequency = %g Hz', ...
        sConfig.monteCarlo.trials,sConfig.monteCarlo.frequencyError_Hz));
    nexttile; semilogy(tNoise.CN0_dBHz,tNoise.DLLRMSE_chip,'-o','LineWidth',sConfig.output.lineWidth); grid on;
    xlabel('C/N0 [dB-Hz]'); ylabel('Envelope DLL RMSE [chip]');
    title('Illustrative independent E/P/L correlator-noise model');
    fctSave(hFigure,'Noise_Effect',sConfig.output,sOut);
end

function fctSave(hFigure,sName,sOutput,sOut)
    if sOutput.savePng
        sTemp = [tempname '.png'];
        oCleanup = onCleanup(@() fctDelete(sTemp));
        exportgraphics(hFigure,sTemp); movefile(sTemp,fullfile(sOut,[sName '.png']),'f');
        clear oCleanup;
    end
    if sOutput.saveFig, savefig(hFigure,fullfile(sOut,[sName '.fig'])); end
    if ~sOutput.figureVisible, close(hFigure); end
end
function fctDelete(sFile)
    if isfile(sFile), delete(sFile); end
end
