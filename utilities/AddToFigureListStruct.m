function AddToFigureListStruct(FH,MFH,type,FHDataFilePath)
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
        FH(ifigs).UserData.FHDataFilePath=FHDataFilePath;
        FH(ifigs).Visible = 'off';
        FH(ifigs).CloseRequestFcn = {@SetFigureInvisible,FH(ifigs)};
        AddElementToList(MFH.UserData.ListFigures,FH(ifigs));
        ImH = findobj(FH(ifigs),'type','image');
        for imh = 1:numel(ImH)
            AddSelectRoi(FH(ifigs),ImH(imh),MFH);
            AddGetDataProfile(FH(ifigs),ImH(imh),MFH);
            AddDefineBorder(FH(ifigs),ImH(imh),MFH);
            AddShiftPixels(FH(ifigs),ImH(imh),MFH);
            %AddPicture(FH(ifigs),ImH(imh),MFH)
            AddSendToCompareAxes(FH(ifigs),ImH(imh),MFH);
            %AddFillBlackLines(FH(end),imh,Wave,MFH);
            %AddCorrectPixels(FH(end),imh,Wave,MFH);
        end
        AddSaveNewFile(FH(ifigs),FH(ifigs),MFH);
    end
    AddSaveFig(FH(ifigs))
end
end