function fctPlotAcq2D(mConvAcq, iPRN, dCmax)
    %% Plot 2-D Acquisition Function

    mAcq = squeeze(mConvAcq.mPower(iPRN, :, :));

    pcolor(mConvAcq.vCodeSearch, ...
           mConvAcq.vDoppSearch / 1e3, ...
           mAcq.');

    shading flat;
    clim([0 dCmax]);
    colorbar;
    axis tight;
    xlabel('Code Delay [chips]');
    ylabel('Doppler Shift [kHz]');
    title(sprintf('2D Time-Frequency Space Search of PRN #%d', iPRN));

end