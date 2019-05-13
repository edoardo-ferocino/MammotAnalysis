function CloseMainFigure(~,~,MFH)
Fields = {'AllDataFigs','SideFigs'};
for ifields = 1:numel(Fields)
    if isfield(MFH.UserData,Fields{ifields})
        FH = MFH.UserData.(Fields{ifields});
        for ifigs = 1:numel(FH)
            if isvalid(FH(ifigs))
                FH(ifigs).CloseRequestFcn = 'closereq';
                delete(FH(ifigs))
            end
        end
    end
end
if findobj('Type','figure','Name','Main panel')==1
    rmpath(genpath('./utilities'))
end
delete(MFH)
end