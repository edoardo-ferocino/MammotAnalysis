function CloseMainFigure(src,event)
if isfield(src.UserData,'AllDataFigs')
    FH = src.UserData.AllDataFigs;
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