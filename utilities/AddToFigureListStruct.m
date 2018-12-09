function AddToFigureListStruct(FH,MFH,type)
switch lower(type)
    case 'side'
        FieldLabel = 'SideFigs';
    case 'data'
        FieldLabel = 'AllDataFigs';
end
if isfield(MFH.UserData,FieldLabel)
    MFH.UserData.(FieldLabel) = [MFH.UserData.(FieldLabel) FH];
else
    MFH.UserData.(FieldLabel) = FH;
end
for ifigs = 1:numel(FH)
    if strcmpi(type,'data')
        FH(ifigs).Visible = 'off';
        FH(ifigs).CloseRequestFcn = {@SetFigureInvisible,FH(ifigs)};
        AddElementToList(MFH.UserData.ListFigures,FH(ifigs));
        AddSendToCompareAxes(MFH.UserData.CompareAxes,FH(ifigs),MFH);
    end
    AddSaveFig(FH(ifigs))
end
end