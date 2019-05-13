function OpenSelectedFigure(src,~)
if isempty(src.String), return; end
figNum = src.UserData.Element(src.Value);
if figNum.UserData.isFFS
    FFS(figNum);
else
    figure(figNum);
end
end