function fctPlotTrackingIQ(tHistory,sConfig4,sOut)
    %% Prompt I/Q constellation.
    sVisible = 'off'; if sConfig4.output.figureVisible, sVisible = 'on'; end
    hFigure = figure('Visible',sVisible,'Position',[100 100 750 750]);
    scatter(tHistory.IP,tHistory.QP,8,[0 0.447 0.741],'filled');
    grid on; axis equal;
    xlim(sConfig4.output.iqAxisLimits); ylim(sConfig4.output.iqAxisLimits);
    xticks(-2:1:2); yticks(-2:1:2);
    xlabel('I_P'); ylabel('Q_P');
    title('Prompt I/Q');
    fctSaveIQFigure(hFigure,'IQ_Constellation',sConfig4.output,sOut);

end

function fctSaveIQFigure(hFigure,sName,sOutput,sOut)
    if sOutput.savePng
        sTemp = [tempname '.png'];
        oCleanup = onCleanup(@() fctDeleteTemporary(sTemp));
        exportgraphics(hFigure,sTemp); movefile(sTemp,fullfile(sOut,[sName '.png']),'f');
        clear oCleanup;
    end
    if sOutput.saveFig, savefig(hFigure,fullfile(sOut,[sName '.fig'])); end
    if ~sOutput.figureVisible, close(hFigure); end
end
function fctDeleteTemporary(sFile)
    if isfile(sFile), delete(sFile); end
end
