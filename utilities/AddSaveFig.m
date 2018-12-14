function AddSaveFig(parentfigure)
MenuName = 'Save Figure';
if isempty(parentfigure.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    parentfigure.UIContextMenu = cmh;
else
    cmh = parentfigure.UIContextMenu;
end
uimenu(cmh,'Label',MenuName,'CallBack',{@SaveFig});

    function SaveFig(~,~)
        StartWait(gcf);
        PathName =uigetdircustom('Select destination');
        if PathName == 0, return, end
        FullPath = fullfile(PathName,parentfigure.Name);
        warning off
        save_figure(FullPath,'-png','-pdf');
        warning on
        msgbox('Figure saved','Success','Help');
        StopWait(gcf);
    end

end