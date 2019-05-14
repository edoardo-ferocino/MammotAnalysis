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
        FH(ifigs).UserData.DataFilePath=FHDataFilePath;
        FH(ifigs).Visible = 'off';
        FH(ifigs).CloseRequestFcn = {@SetFigureInvisible,FH(ifigs)};
        AddElementToList(MFH.UserData.ListFigures,FH(ifigs));
        AddInfoEntry(MFH,MFH.UserData.ListFigures,FH(ifigs),MFH);
        if isfield(FH(ifigs).UserData,'DatData')
            SumChan = squeeze(sum(FH(ifigs).UserData.DatData,3));
        end
        ImH = findobj(FH(ifigs),'type','image');
        for imh = 1:numel(ImH)
            if isfield(FH(ifigs).UserData,'Filters')
                AddGetTableInfo(FH(ifigs),ImH(imh),FH(ifigs).UserData.Filters,FH(ifigs).UserData.rows,FH(ifigs).UserData.FitData);
            end
            if isfield(FH(ifigs).UserData,'DatData')
                AddPickCurve(FH(ifigs),ImH(imh),SumChan,MFH);
            end
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