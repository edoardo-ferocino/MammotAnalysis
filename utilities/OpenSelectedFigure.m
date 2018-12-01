function OpenSelectedFigure(src,event)
   figNum = src.UserData(src.Value); 
   FFS(figNum);
end