function fctPlotTask4(sTask4,sConfig4,sOut)
    %% Plot saved-signal acquisition and tracking results.
    sVisible = 'off'; if sConfig4.output.figureVisible, sVisible = 'on'; end
    dWidth = sConfig4.output.lineWidth;
    sAcq = sTask4.sAcquisition;
    tHistory = sTask4.sTracking.tHistory;
    vTime = tHistory.Time_s*1e3;

    fctPlotAcq3D(sAcq,sConfig4.output,sOut);
    fctPlotTrackingIQ(tHistory,sConfig4,sOut);

    mRange = [vTime(1) vTime(end); sConfig4.output.correlationZoom_ms(:).'];
    cName = {'Correlators','Correlators_Zoom'};
    for iView = 1:2
        hFigure = figure('Visible',sVisible,'Position',[100 100 1100 850]); tiledlayout(4,1);
        cField = {{'IE','IP','IL'},{'QE','QP','QL'},{'EarlyPower','PromptPower','LatePower'}};
        cLabel = {'I component','Q component','Correlation power'};
        for iPlot = 1:3
            nexttile; plot(vTime,tHistory{:,cField{iPlot}},'LineWidth',dWidth);
            grid on; ylabel(cLabel{iPlot}); xlabel('Time [ms]'); legend('Early','Prompt','Late');
        end
        nexttile; stairs(vTime-0.5*median(diff(vTime)),tHistory.NavigationBit,'LineWidth',dWidth);
        grid on; ylabel('Navigation bit'); xlabel('Time [ms]'); ylim([-1.5 1.5]);
        xlim(findall(hFigure,'Type','axes'),mRange(iView,:));
        fctSaveFigure(hFigure,cName{iView},sConfig4.output,sOut);
    end

    hFigure = figure('Visible',sVisible,'Position',[100 100 1100 750]); tiledlayout(3,1);
    cData = {tHistory.DLL_chip,2*pi*tHistory.PLL_cycle,tHistory.FLL_Hz};
    cLabel = {'DLL [chip]','PLL [rad]','FLL [Hz]'};
    for iPlot = 1:3
        nexttile; plot(vTime,cData{iPlot},'LineWidth',dWidth);
        grid on; ylabel(cLabel{iPlot}); xlabel('Time [ms]');
    end
    fctSaveFigure(hFigure,'Discriminators',sConfig4.output,sOut);

    hFigure = figure('Visible',sVisible,'Position',[100 100 1100 750]); tiledlayout(3,1);
    cData = {tHistory.DelayMid_chip,tHistory.DopplerMid_Hz,2*pi*tHistory.PhaseMid_cycle};
    cLabel = {'Code delay [chip]','Doppler [Hz]','Carrier phase [rad]'};
    for iPlot = 1:3
        nexttile; plot(vTime,cData{iPlot},'LineWidth',dWidth);
        grid on; ylabel(cLabel{iPlot}); xlabel('Time [ms]');
    end
    fctSaveFigure(hFigure,'States',sConfig4.output,sOut);

    hFigure = figure('Visible',sVisible,'Position',[100 100 1100 750]); tiledlayout(3,1);
    cData = {tHistory.PhaseError_cycle*360,tHistory.DopplerError_Hz,tHistory.CodeError_chip};
    cLabel = {'Phase error [deg]','Doppler error [Hz]','Code error [chip]'};
    for iPlot = 1:3
        nexttile; plot(vTime,cData{iPlot},'LineWidth',dWidth);
        grid on; ylabel(cLabel{iPlot}); xlabel('Time [ms]');
    end
    fctSaveFigure(hFigure,'Errors',sConfig4.output,sOut);
end

function fctSaveFigure(hFigure,sName,sOutput,sOut)
    if sOutput.savePng
        sTemp = [tempname '.png'];
        oCleanup = onCleanup(@() fctRemoveTemporary(sTemp));
        exportgraphics(hFigure,sTemp); movefile(sTemp,fullfile(sOut,[sName '.png']),'f');
        clear oCleanup;
    end
    if sOutput.saveFig, savefig(hFigure,fullfile(sOut,[sName '.fig'])); end
    if ~sOutput.figureVisible, close(hFigure); end
end
function fctRemoveTemporary(sFile)
    if isfile(sFile), delete(sFile); end
end
