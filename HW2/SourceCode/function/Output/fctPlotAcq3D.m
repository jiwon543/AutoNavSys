function fctPlotAcq3D(sAcq,sOutput,sOut)
    %% Full acquisition surface and a second figure around the detected peak.
    sVisible = 'off'; if sOutput.figureVisible, sVisible = 'on'; end
    dPeak = max(sAcq.mPower,[],'all');
    mNormalized = sAcq.mPower / dPeak;
    cName = {'Acquisition','Acquisition_Zoom'};
    for iView = 1:2
        vCode = true(size(sAcq.vCodeSearch));
        vDoppler = true(size(sAcq.vDopplerSearch));
        if iView == 2
            vCode = abs(sAcq.vCodeSearch-sAcq.dCodeDelay_chip)<=sOutput.acquisitionZoomCode_chip;
            vDoppler = abs(sAcq.vDopplerSearch-sAcq.dDoppler_Hz)<=sOutput.acquisitionZoomDoppler_Hz;
        end
        hFigure = figure('Visible',sVisible,'Position',[100 100 1100 700]);
        surf(sAcq.vCodeSearch(vCode),sAcq.vDopplerSearch(vDoppler)/1e3, ...
            mNormalized(vCode,vDoppler).','EdgeColor','none');
        hold on;
        plot3(sAcq.dCodeDelay_chip,sAcq.dDoppler_Hz/1e3,1,'ro', ...
            'MarkerFaceColor','r','MarkerSize',7,'LineWidth',sOutput.lineWidth);
        grid on; axis tight; zlim([0 1.1]); view(45,30); colorbar; clim([0 1]);
        xlabel('Code delay [chip]'); ylabel('Doppler [kHz]'); zlabel('Normalized correlation power');
        if iView == 1
            title(sprintf('Acquisition - PRN %d (full search)',sAcq.iPRN));
        else
            title(sprintf('PRN %d peak: %.2f chip, %.0f Hz',sAcq.iPRN,sAcq.dCodeDelay_chip,sAcq.dDoppler_Hz));
        end
        rotate3d(hFigure,'on');
        if sOutput.savePng
            sTemp = [tempname '.png'];
            oCleanup = onCleanup(@() fctDeleteTemporary(sTemp));
            exportgraphics(hFigure,sTemp); movefile(sTemp,fullfile(sOut,[cName{iView} '.png']),'f');
            clear oCleanup;
        end
        if sOutput.saveFig, savefig(hFigure,fullfile(sOut,[cName{iView} '.fig'])); end
        if ~sOutput.figureVisible, close(hFigure); end
    end
end
function fctDeleteTemporary(sFile)
    if isfile(sFile), delete(sFile); end
end
