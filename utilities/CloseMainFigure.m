function CloseMainFigure(src,event)
H = guidata(gcbo);
if isfield(H,'FH')
    FH = H.FH;
    for ifigs = 1:numel(FH)
        FH(ifigs).CloseRequestFcn = 'closereq';
        delete(FH(ifigs))
    end
end
if isfield(src.UserData,'SideFigs')
   for ifigs = 1:numel(src.UserData.SideFigs) 
       delete(src.UserData.SideFigs(ifigs));
   end
end
delete(src)
end