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
tData = [];
for iw = 1:numel(Wavelengths)
    tData = [[Data(iw).Gate(:).Counts] tData];
end
tData(tData == 0) = nan;
PercVal = GetPercentile(tData,PercFract);
for iw = 1:numel(Wavelengths)
    subplot1(iw);
    %tData = [Data(iw).Gate(:).Counts]; tData(tData==0)=nan;
    %PercVal = GetPercentile(tData,PercFract);
    imh = imagesc(Data(iw).Gate(1).Counts,[0 PercVal]);
    colormap pink, shading interp, axis image;
    subH(iw).YDir = 'reverse';
    SetPushButtons(FH,subH(iw),iw,1,numgate);
    title({num2str(Wavelengths(iw)) ...
        [num2str(Data(iw).Gate(1).TemporalInterval(1),'%.0f') '-' num2str(Data(iw).Gate(1).TemporalInterval(2),'%.0f') ' ps']});
    colorbar('westoutside')
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
        ContainerH = CreateContainer(parentfigure,'OuterPosition',[SubH.OuterPosition(1)+SubH.OuterPosition(3)/2 SubH.Position(2)+0.9*SubH.Position(4) 0.04 0.08]);
        UpPushH = CreatePushButton(ContainerH,'String','Up','Units','normalized',...
            'Position',[0 0 1 1/2],'Callback',{@Clicked,SubH,SubID,'up'});
        DownPushH = CreatePushButton(ContainerH,'String','Down','Units','normalized',...
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
        %teData = [Data(SubID).Gate(:).Counts]; teData(teData==0)=nan;
        %PercVal = GetPercentile(teData,PercFract);
        imagesc(SubH,Data(SubID).Gate(SubH.UserData.ActualVal).Counts,[0 PercVal]);
        colormap pink, shading interp, axis image;
        SubH.YDir = 'reverse';
        title(SubH,{num2str(Wavelengths(SubID)) ...
            [num2str(Data(SubID).Gate(SubH.UserData.ActualVal).TemporalInterval(1),'%.0f') '-' num2str(Data(SubID).Gate(SubH.UserData.ActualVal).TemporalInterval(2),'%.0f') ' ps']});
        colorbar(SubH,'westoutside');
        StopWait(ancestor(src,'figure'));
    end
end