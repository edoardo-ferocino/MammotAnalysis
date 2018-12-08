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
for ifh = 1:numel(FH)
   AddSaveFig(FH(ifh)) 
end

end