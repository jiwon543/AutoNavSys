function fctPlotTask1(sTask1,sConfig,sOut)
    %% One call exports all correlation and discriminator figures.
    
    cAxis = {'Code delay error [chip]','Doppler error [Hz]','Carrier phase error [cycle]'};
    cFile = {'Code','Doppler','Phase'};
    sVisible = 'off'; if sConfig.output.figureVisible, sVisible = 'on'; end
    for iSweep = 1:3
        vError = sTask1(iSweep).vError;
        hFigure = figure('Name',['Task 1 Correlation - ' cFile{iSweep}],'Visible',sVisible,'Position',sConfig.output.figurePosition(:).');
        mZ = sTask1(iSweep).mFirst;
        plot(vError,[real(mZ),imag(mZ)],'LineWidth',sConfig.output.lineWidth);
        grid on; xlabel(cAxis{iSweep}); ylabel('Normalized correlation');
        legend('I_E','I_P','I_L','Q_E','Q_P','Q_L','Location','eastoutside');
        title('Noise-free');
        fctSaveTask1Figure(hFigure,sOut,['Correlation_' cFile{iSweep}],sConfig.output);
    end

    %% Three corresponding discriminator families, noise-free.
    cDisc = {'mDLL','mFLL','mPLL'};
    cLegend = {{'Envelope','Power','Dot product'}, ...
               {'Normalized cross','Cross sign(dot)','atan2(cross,dot)'}, ...
               {'atan2(Q,I)','atan(Q/I)','Q sign(I)'}};
    cY = {'DLL [chip]','FLL [Hz]','PLL [cycle]'};
    for iSweep = 1:3
        hFigure = figure('Name',['Task 1 Discriminator - ' cFile{iSweep}],'Visible',sVisible,'Position',sConfig.output.figurePosition(:).');
        plot(sTask1(iSweep).vError,sTask1(iSweep).(cDisc{iSweep}),'LineWidth',sConfig.output.lineWidth);
        grid on; xlabel(cAxis{iSweep}); ylabel(cY{iSweep});
        legend(cLegend{iSweep},'Location','eastoutside'); title('Noise-free');
        fctSaveTask1Figure(hFigure,sOut,['Discriminator_' cFile{iSweep}],sConfig.output);
    end

end

function fctSaveTask1Figure(hFigure,sOut,sName,sOutput)
    if sOutput.savePng
        % Export to a temporary path before moving to the Korean output path.
        sTemporary = [tempname '.png'];
        oCleanup = onCleanup(@() fctRemoveTemporary(sTemporary));
        exportgraphics(hFigure,sTemporary);
        movefile(sTemporary,fullfile(sOut,[sName '.png']),'f');
        clear oCleanup;
    end
    if sOutput.saveFig, savefig(hFigure,fullfile(sOut,[sName '.fig'])); end
    if ~sOutput.figureVisible, close(hFigure); end
end

function fctRemoveTemporary(sFile)
    if isfile(sFile), delete(sFile); end
end
