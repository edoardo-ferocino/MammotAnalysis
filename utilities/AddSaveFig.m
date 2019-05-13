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
        StartWait(parentfigure);
        PathName =uigetdircustom('Select destination');
        if PathName == 0, StopWait(gcf); return, end
        FullPath = fullfile(PathName,parentfigure.Name);
        warning off
        figh = copyfig(parentfigure); 
        figh.reset;
        figure(figh);
        SetAxesAppeareance(findobj(figh,'type','axes'));
%         axh= findobj(parentfigure,'type','axes');
%         for iaxh = 1:numel(axh)
%            OrigTitle{iaxh}=axh(iaxh).Title;
%            axh(iaxh).Title = [];
%         end
        save_figure(FullPath,figh,'-png','-pdf');    
%         for iaxh = 1:numel(axh)
%            axh(iaxh).Title=OrigTitle{iaxh};
%         end
        delete(figh);
        warning on
        msgbox('Figure saved','Success','Help');
        %delete(figh);
        StopWait(parentfigure);
    end

end