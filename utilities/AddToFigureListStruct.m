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
    StartWait(FH(ifigs));
    if ~isfield(FH(ifigs).UserData,'FigCategory')
        FH(ifigs).UserData.FigCategory = 'NoCategory';
    end
    if strcmpi(type,'data')
        FH(ifigs).UserData.DataFilePath=FHDataFilePath;
        FH(ifigs).Visible = 'off';
        FH(ifigs).CloseRequestFcn = {@SetFigureInvisible,FH(ifigs)};
        AddElementToList(MFH.UserData.ListFigures,FH(ifigs));
        AddInfoEntry(MFH,MFH.UserData.ListFigures,FH(ifigs),MFH);
        if isfield(FH(ifigs).UserData,'VisualDatData')||strcmpi(FH(ifigs).UserData.FigCategory,'ReferenceArea')
            SumChan = squeeze(sum(FH(ifigs).UserData.VisualDatData,3));
        end
        ImH = findobj(FH(ifigs),'type','image');
        for imh = 1:numel(ImH)
            if isfield(FH(ifigs).UserData,'Filters')
                AddGetTableInfo(FH(ifigs),ImH(imh),FH(ifigs).UserData.Filters,FH(ifigs).UserData.rows,FH(ifigs).UserData.FitData);
            end
            if isfield(FH(ifigs).UserData,'VisualDatData')
                AddPickCurve(FH(ifigs),ImH(imh),SumChan,MFH);
            end
            AddApplyReferenceMask(FH(ifigs),ImH(imh),MFH);
            if strcmpi(FH(ifigs).UserData.FigCategory,'ReferenceArea')
                AddSelectReferenceArea(FH(ifigs),ImH(imh),SumChan,MFH)
            end
            if strcmpi(FH(ifigs).UserData.FigCategory,'GatesImage')
                AddShowGatedCurve(FH(ifigs),ImH(imh),MFH)
            end
            if strcmpi(FH(ifigs).UserData.FigCategory,'Spectral')||strcmpi(FH(ifigs).UserData.FigCategory,'MuaMus')||strcmpi(FH(ifigs).UserData.FigCategory,'2-step fit')
                AddPlotSpectra(FH(ifigs),ImH(imh),MFH);
            end
            AddShowTrimmerPoint(FH(ifigs),ImH(imh),MFH);
            AddSelectRoi(FH(ifigs),ImH(imh),MFH);
            AddGetDataProfile(FH(ifigs),ImH(imh),MFH);
            AddDefineBorder(FH(ifigs),ImH(imh),MFH);
            AddShiftPixels(FH(ifigs),ImH(imh),MFH);
            AddSetColorbar(FH(ifigs),ImH(imh),MFH);
            AddFilterTool(FH(ifigs),ImH(imh),MFH);
            %AddPicture(FH(ifigs),ImH(imh),MFH)
            AddSendToCompareAxes(FH(ifigs),ImH(imh),MFH);
            %AddFillBlackLines(FH(end),imh,Wave,MFH);
            %AddCorrectPixels(FH(end),imh,Wave,MFH);
        end
        AddSaveNewFile(FH(ifigs),FH(ifigs),MFH);
        AddNodeToTree(MFH,FH(ifigs));
        preunits = FH(ifigs).Units; FH(ifigs).Units = 'normalized';
        CreatePushButton(FH(ifigs),'units','normalized','String','Figure list','Position',[0.95 0 0.05 0.05],'CallBack','CreateOrFindFig(''Figure list'',''uifigure'',true);');
        CreatePushButton(FH(ifigs),'units','normalized','String','Main Panel','Position',[0.95 0.05 0.05 0.05],'CallBack','CreateOrFindFig(''Main panel'');');
        FH(ifigs).Units = preunits;
    elseif contains(FH(ifigs).UserData.FigCategory,'roi','IgnoreCase',true)||contains(FH(ifigs).UserData.FigCategory,'referenceroi','IgnoreCase',true)||contains(FH(ifigs).UserData.FigCategory,'ReferenceMaskStats','IgnoreCase',true)
        AddNodeToTree(MFH,FH(ifigs));
    end
    AddSaveFig(FH(ifigs))
    warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame')
    javaFrame = get(FH(ifigs),'JavaFrame');
    javaFrame.setFigureIcon(javax.swing.ImageIcon(fullfile(pwd,'utilities','Logo.PNG')));
    warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame')
    StopWait(FH(ifigs));
end
end