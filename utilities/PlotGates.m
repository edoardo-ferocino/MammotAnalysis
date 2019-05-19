function PlotGates(ParentFH,MFH)
Data = ParentFH.UserData.GatesWaveS;
[~,FileName]=fileparts(ParentFH.UserData.DatFilePath);
PercFract = 95;
FH = CreateOrFindFig(['Gates - ' FileName],'WindowState','maximized');
FH.UserData.VisualDatData = ParentFH.UserData.VisualDatData;
FH.UserData.ActualDatData = ParentFH.UserData.ActualDatData;
FH.UserData.ActualIrfData = ParentFH.UserData.ActualIrfData;
FH.UserData.TrsSet = ParentFH.UserData.TrsSet;
FH.UserData.CompiledHeaderData = ParentFH.UserData.CompiledHeaderData;
FH.UserData.Numel2Pad = ParentFH.UserData.Numel2Pad;
FH.UserData.HeaderData = ParentFH.UserData.HeaderData;
FH.UserData.SubHeaderData = ParentFH.UserData.SubHeaderData;
FH.UserData.DataType = ParentFH.UserData.DataType;
FH.UserData.DataSize = ParentFH.UserData.DataSize;
FH.UserData.DatFilePath=ParentFH.UserData.DatFilePath;
FH.UserData.InfoData.Name = ParentFH.UserData.InfoData.Name;
FH.UserData.InfoData.Value = ParentFH.UserData.InfoData.Value;
FH.UserData.TrsSet = ParentFH.UserData.TrsSet;
FH.UserData.FigCategory = 'GatesImage';
FH.UserData.GatesWaves = ParentFH.UserData.GatesWaveS;
StartWait(FH);
Wavelengths = MFH.UserData.Wavelengths;
numwave = numel(MFH.UserData.Wavelengths);
numgate = str2double(MFH.UserData.NumGate.String);
nSub = numSubplots(numel(Wavelengths));

for iw = 1:numel(Wavelengths)
    tData = [Data(iw).Gates(:).Counts];
    PercVal(iw) = GetPercentile(tData,PercFract);
end

subH = subplot1(nSub(1),nSub(2));
for iw = 1:numwave
    subplot1(iw);
    PlotPage(iw,1);
    SetPushButtons(FH,subH(iw),iw,1,numgate);
end
delete(subH(iw+1:end))
%FH.UserData.SubToAttachGatedCurvesAxes = subH(end);
StopWait(FH)
AddToFigureListStruct(FH,MFH,'data',FH.UserData.DatFilePath);

    function SetPushButtons(parentfigure,SubH,SubID,MinVal,MaxVal)
        ContainerH = CreateContainer(parentfigure,'OuterPosition',[SubH.OuterPosition(1)+SubH.OuterPosition(3)/4 SubH.Position(2)+0.9*SubH.Position(4) 0.07 0.08]);
        DecreasePushH = CreatePushButton(ContainerH,'String','Decrease','Units','normalized',...
            'Position',[0 0 0.5 1/2],'Callback',{@Clicked,SubH,SubID,'down'});
        CreatePushButton(ContainerH,'String','Increases','Units','normalized',...
            'Position',DecreasePushH.Position+[0 1/2 0 0],'Callback',{@Clicked,SubH,SubID,'up'});
        CreateEdit(ContainerH,'String','1','Units','normalized',...
            'Position',DecreasePushH.Position+[DecreasePushH.Position(3) 0 0 0],'Callback',{@GotoPage,SubH,SubID});
        CreateText(ContainerH,'String','Goto gate #','Units','normalized',...
            'Position',DecreasePushH.Position+[DecreasePushH.Position(3) 0.5 0 0]);
        SubH.UserData.WaveID = SubID;
        SubH.UserData.MinVal = MinVal;SubH.UserData.MaxVal = MaxVal;
        SubH.UserData.ActualGateVal = 1;
    end
    function Clicked(src,~,SubH,SubID,type)
        if strcmpi(type,'up')
            delta = 1;
            if SubH.UserData.ActualGateVal >=SubH.UserData.MaxVal, delta = 0; end
        else
            delta = -1;
            if SubH.UserData.ActualGateVal <=SubH.UserData.MinVal, delta = 0; end
        end
        if delta == 0, return, end
        StartWait(ancestor(src,'figure'));
        SubH.UserData.ActualGateVal = SubH.UserData.ActualGateVal+delta;
        % needed if the user is too fast in clicking
        if SubH.UserData.ActualGateVal>=SubH.UserData.MaxVal
            SubH.UserData.ActualGateVal = SubH.UserData.MaxVal;
        end
        if SubH.UserData.ActualGateVal<=SubH.UserData.MinVal
            SubH.UserData.ActualGateVal = SubH.UserData.MinVal;
        end
        PlotPage(SubID,SubH.UserData.ActualGateVal);
        StopWait(ancestor(src,'figure'));
    end
    function GotoPage(src,~,SubH,SubID)
        StartWait(ancestor(src,'figure'));
        PageID = str2double(src.String);
        SubH.UserData.ActualGateVal = PageID;
        % needed if the user is too fast in clicking
        if SubH.UserData.ActualGateVal>=SubH.UserData.MaxVal
            SubH.UserData.ActualGateVal = SubH.UserData.MaxVal;
        end
        if SubH.UserData.ActualGateVal<=SubH.UserData.MinVal
            SubH.UserData.ActualGateVal = SubH.UserData.MinVal;
        end
        PlotPage(SubID,SubH.UserData.ActualGateVal);
        StopWait(ancestor(src,'figure'));
    end
    function imh = PlotPage(iw,ig)
        imh = imagesc(subH(iw),Data(iw).Gates(ig).Counts,[0 PercVal(iw)]);
        SetAxesAppeareance(subH(iw),'southoutside');
        title(subH(iw),{num2str(Wavelengths(iw)) ...
            [num2str(Data(iw).Gates(ig).TimeArray(1),'%.0f') '-' ...
            num2str(Data(iw).Gates(ig).TimeArray(end),'%.0f') ' ps.' ...
            num2str(ig) '/' num2str(numgate)]});
    end
end