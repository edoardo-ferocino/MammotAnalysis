InitScript
MFH = FFS('Name','Main panel','NumberTitle','off'); %MFH.Units = 'normalized';
H = guihandles(MFH);
H.MFH = MFH;
MFH.UserData.Name = MFH.Name;
addpath('./utilities');
MFH.CloseRequestFcn = {@CloseMainFigure,MFH};
MFH.UserData.LoadFileContainer = CreateContainer(MFH,'Title','Load files','OuterPosition',[0.02 0.85 0.2 0.15]);%,'BorderType','none');
MFH.UserData.LoadFit = CreatePushButton(MFH.UserData.LoadFileContainer,'String','Load fit file',...
    'Units','normalized','Position',[0 0 0.2 1/4],'Callback',{@GetFilePath,'fit',MFH});
MFH.UserData.DispFitFilePath = CreateEdit(MFH.UserData.LoadFileContainer,'Units','normalized',...
    'Position',MFH.UserData.LoadFit.Position+[0.25 0 0.30 0],'HorizontalAlignment','Left','Enable','inactive');
MFH.UserData.LoadDat = CreatePushButton(MFH.UserData.LoadFileContainer,'Units','normalized',...
    'Position',MFH.UserData.LoadFit.Position+[0 1/4 0 0],'String','Load dat file','Callback',{@GetFilePath,'dat',MFH});
MFH.UserData.DispDatFilePath = CreateEdit(MFH.UserData.LoadFileContainer,'Units','normalized',...
    'Position',MFH.UserData.LoadDat.Position+[0.25 0 0.30 0],'HorizontalAlignment','Left','Enable','inactive');
MFH.UserData.LoadIrf = CreatePushButton(MFH.UserData.LoadFileContainer,'Units','normalized',...
    'Position',MFH.UserData.LoadDat.Position+[0 1/4 0 0],'String','Load irf file','Callback',{@GetFilePath,'irf',MFH});
MFH.UserData.DispIrfFilePath = CreateEdit(MFH.UserData.LoadFileContainer,'units','normalized',...
    'Position',MFH.UserData.LoadIrf.Position+[0.25 0 0.3 0],'HorizontalAlignment','Left','Enable','inactive');
MFH.UserData.LoadTRSSet = CreatePushButton(MFH.UserData.LoadFileContainer,'units','normalized',...
    'Position',MFH.UserData.LoadIrf.Position+[0 1/4 0 0],'String','Load TRS set file','Callback',{@GetFilePath,'trs',MFH});
MFH.UserData.DispTRSSetFilePath = CreateEdit(MFH.UserData.LoadFileContainer,'Units','normalized',...
    'Position',MFH.UserData.LoadTRSSet.Position+[0.25 0 0.3 0],'HorizontalAlignment','Left','Enable','inactive');
ch = CreateContainer(MFH,'OuterPosition',[0.02 0.65 0.2 0.15]);
MFH.UserData.ListFigures = CreateListBox(ch,'Units','normalized','Position',[0 0 1 1],'CallBack',{@OpenSelectedFigure});
MFH.UserData.MainActionsContainer = CreateContainer(MFH,'Title','Main actions','OuterPosition',[0.25 0.85 0.2 0.15]);%,'BorderType','none');
MFH.UserData.ReadFitFile = CreatePushButton(MFH.UserData.MainActionsContainer,'String','Read fit file',...
    'Units','normalized','Position',[0 0 0.2 1/4],'Callback',{@ReadFitData,MFH});
MFH.UserData.PlotRawScan = CreatePushButton(MFH.UserData.MainActionsContainer,'String','Plot raw scan',...
    'Units','normalized','Position',MFH.UserData.ReadFitFile.Position+[0 1/4 0.05 0],'Callback',{@PlotScan,MFH});
MFH.UserData.SumChannelsRawDatFile = CreatePushButton(MFH.UserData.MainActionsContainer,'String','Sum channel raw scan',...
    'Units','normalized','Position',MFH.UserData.PlotRawScan.Position+[0 1/4 0.15 0],'Callback',{@SumChannels,MFH});
MFH.UserData.OpenGatePage = CreatePushButton(MFH.UserData.MainActionsContainer,'String','Plot gates',...
    'Units','normalized','Position',MFH.UserData.PlotRawScan.Position+[0.3 0 0.05 0],'Callback',{@OpenGatePage});



guidata(MFH,H)


