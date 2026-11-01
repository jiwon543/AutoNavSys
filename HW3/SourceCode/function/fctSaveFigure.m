function fctSaveFigure(h, sDirectory, sName)
    exportgraphics(h, fullfile(sDirectory, [sName '.png']), 'Resolution', 160);
    savefig(h, fullfile(sDirectory, [sName '.fig']));
    if strcmp(get(h, 'Visible'), 'off')
        close(h);
    end
end
