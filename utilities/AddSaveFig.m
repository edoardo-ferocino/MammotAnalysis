function AddSaveFig(parentfigure,object2attach,figentry,infodata)
%(ctxmh,figentry,infodata)
MenuName = 'Save Fig';
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
uimenu(cmh,'Label',MenuName,'CallBack',{CallBackHandle,parentfigure});

uimenu(ctxmh,'Label',figentry.Name,'Callback',{@GetInfoData,infodata});
    function GetInfoData(~,~,infodata)
        FH = figure(468);
        FH.ToolBar = 'none'; FH.MenuBar = 'none'; FH.Name = ['Report: ' figentry.Name];
        FH.NumberTitle = 'off';
        if isrow(infodata.Name), infodata.Name = infodata.Name'; end
        if isrow(infodata.Value), infodata.Value = infodata.Value'; end
        tbh = uitable(FH,'RowName',infodata.Name,'Data',infodata.Value,'ColumnName','Val');
        tbh.Position([3 4]) = tbh.Extent([3 4]);
        FH.Position = tbh.Position + [0 0 70 40];
        movegui(FH,'southeast')
    end

end