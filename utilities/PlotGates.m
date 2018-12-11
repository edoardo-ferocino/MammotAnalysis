function PlotGates(Data,MFH)
[~,NameFile,~] = fileparts(MFH.UserData.DispDatFilePath.String);
PercFract = 95;
FH = findobj('Type','figure','-and','Name',['Gates - ' NameFile]);
if ~isempty(FH)
    figure(FH);
else
    FH = FFS('Name',['Gates - ' NameFile]);
end
Wavelengths = MFH.UserData.Wavelengths;
numgate = str2double(MFH.UserData.NumGate.String);
nSub = numSubplots(numel(Wavelengths));
subH = subplot1(nSub(1),nSub(2));

for iw = 1:numel(Wavelengths)
    tData = [Data(iw).Gate(:).Counts];
    tData(tData == 0) = nan;
    PercVal(iw) = GetPercentile(tData,PercFract);
end

for iw = 1:numel(Wavelengths)
    subplot1(iw);
    %tData = [Data(iw).Gate(:).Counts]; tData(tData==0)=nan;
    %PercVal = GetPercentile(tData,PercFract);
    imh = PlotPage(iw,1);
    SetPushButtons(FH,subH(iw),iw,1,numgate);
    AddDefineBorder(FH,imh,MFH)
    AddSelectRoi(FH,imh,MFH)
end
delete(subH(iw+1:end))


for ifigs = 1:numel(FH)
    FH(ifigs).Visible = 'off';
    FH(ifigs).CloseRequestFcn = {@SetFigureInvisible,FH(ifigs)};
    AddElementToList(MFH.UserData.ListFigures,FH(ifigs));
end
if isfield(MFH.UserData,'AllDataFigs')
    MFH.UserData.AllDataFigs = [MFH.UserData.AllDataFigs FH];
else
    MFH.UserData.AllDataFigs = FH;
end

StopWait(MFH)

    function SetPushButtons(parentfigure,SubH,SubID,MinVal,MaxVal)
        ContainerH = CreateContainer(parentfigure,'OuterPosition',[SubH.OuterPosition(1)+SubH.OuterPosition(3)/4 SubH.Position(2)+0.9*SubH.Position(4) 0.04 0.08]);
        UpPushH = CreatePushButton(ContainerH,'String','Up','Units','normalized',...
            'Position',[0 0 1 1/2],'Callback',{@Clicked,SubH,SubID,'up'});
        CreatePushButton(ContainerH,'String','Down','Units','normalized',...
            'Position',UpPushH.Position+[0 1/2 0 0],'Callback',{@Clicked,SubH,SubID,'down'});
        SubH.UserData.MinVal = MinVal;SubH.UserData.MaxVal = MaxVal;
        SubH.UserData.ActualVal = 1;
        
    end
    function Clicked(src,~,SubH,SubID,type)
        if strcmpi(type,'up')
            delta = 1;
            if SubH.UserData.ActualVal >=SubH.UserData.MaxVal, delta = 0; end
        else
            delta = -1;
            if SubH.UserData.ActualVal <=SubH.UserData.MinVal, delta = 0; end
        end
        if delta == 0, return, end
        StartWait(ancestor(src,'figure'));
        SubH.UserData.ActualVal = SubH.UserData.ActualVal+delta;
        % needed if the user is too fast in clicking
        if SubH.UserData.ActualVal>=SubH.UserData.MaxVal
            SubH.UserData.ActualVal = SubH.UserData.MaxVal;
        end
        if SubH.UserData.ActualVal<=SubH.UserData.MinVal
            SubH.UserData.ActualVal = SubH.UserData.MinVal;
        end
        PlotPage(SubID,SubH.UserData.ActualVal);
        StopWait(ancestor(src,'figure'));
    end
    function imh = PlotPage(iw,ig)
        imh = imagesc(subH(iw),Data(iw).Gate(ig).Counts,[0 PercVal(iw)]);
        colormap pink, shading interp, axis image;
        subH(iw).YDir = 'reverse';
        title(subH(iw),{num2str(Wavelengths(iw)) ...
            [num2str(Data(iw).Gate(ig).TemporalInterval(1),'%.0f') '-' ...
            num2str(Data(iw).Gate(ig).TemporalInterval(2),'%.0f') ' ps.' ...
            num2str(ig) '/' num2str(numgate)]});
        if ~isfield(subH(iw).UserData,'Cbh')
            subH(iw).UserData.Cbh = colorbar(subH(iw),'southoutside');
        end
    end
end