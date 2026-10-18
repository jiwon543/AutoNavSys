function fctPlotAcq3D(mConvAcq, iPRN)
    %% Plot 3-D Time-Frequency Acquisition Function
    mAcq = squeeze(mConvAcq.mPower(iPRN, :, :));

    surf(mConvAcq.vDoppSearch / 1e3, ...
         mConvAcq.vCodeSearch, ...
         mAcq, ...
         'EdgeColor', 'none');

    grid on;
    xlabel('Doppler Shift [kHz]');
    ylabel('Code Delay [chips]');
    zlabel('Correlation');
    title(sprintf('3D Time-Frequency Space Search of PRN #%d', iPRN));

end