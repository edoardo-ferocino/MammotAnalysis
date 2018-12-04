function OpenSelectedFigure(src,event)
figNum = src.UserData.Element(src.Value);
FH = FFS(figNum);

if isfield(FH.UserData,'InfoFitData')
    src.UserData.CntxMH = uicontextmenu(src.Parent);
    src.UIContextMenu = src.UserData.CntxMH;
    CreateInfoUIContextMenu(src.UIContextMenu,FH.UserData.InfoFitData);
else
    src.UserData = rmfield(src.UserData,'CntxMH');
    src.UIContextMenu = [];    
end
end