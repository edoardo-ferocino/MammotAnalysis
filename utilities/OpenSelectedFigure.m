function OpenSelectedFigure(src,~)
if isempty(src.String), return; end
figNum = src.UserData.Element(src.Value);
FFS(figNum);
end