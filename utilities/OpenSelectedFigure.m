function OpenSelectedFigure(src,~)
if isempty(src.String), return; end
figNum = src.UserData.Element(src.Value);
FH = FFS(figNum);

% if isfield(FH.UserData,'InfoData')
%     src.UserData.CntxMH = uicontextmenu(src.Parent);
%     src.UIContextMenu = src.UserData.CntxMH;
%     CreateInfoUIContextMenu(src.UIContextMenu,FH.UserData.InfoFitData);
% else
%     src.UIContextMenu = [];    
% end
end