function CloseMainFigure(~,~,MFH)
if isfield(MFH.UserData,'AllDataFigs')
    FH = MFH.UserData.AllDataFigs;
    for ifigs = 1:numel(FH)
        if isvalid(FH(ifigs))
            FH(ifigs).CloseRequestFcn = 'closereq';
            delete(FH(ifigs))
        end
    end
end
if isfield(MFH.UserData,'SideFigs')
   for ifigs = 1:numel(MFH.UserData.SideFigs)
       if isvalid(MFH.UserData.SideFigs(ifigs))
           delete(MFH.UserData.SideFigs(ifigs));
       end
   end
end
delete(MFH)
end