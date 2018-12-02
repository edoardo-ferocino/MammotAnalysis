InitScript
MFH = FFS('Name','Main panel'); %MFH.Units = 'normalized';
H = guihandles(MFH);
H.MFH = MFH;
addpath('./utilities');
H.MFH.CloseRequestFcn = {@CloseMainFigure};
H.LoadFileContainer = CreateContainer(MFH,'Title','Load files','OuterPosition',[0.02 0.85 0.2 0.15]);
H.LoadFit = CreatePushButton(H.LoadFileContainer,'String','Load fit file','Callback',{@GetFilePath,'fit'});
H.DispFitFilePath = CreateEdit(H.LoadFileContainer,'Position',H.LoadFit.Position+[80 0 100 0],'HorizontalAlignment','Left','Enable','inactive');
H.LoadDat = CreatePushButton(H.LoadFileContainer,'Position',H.LoadFit.Position+[0 20 0 0],'String','Load dat file','Callback',{@GetFilePath,'dat'});
H.DispDatFilePath = CreateEdit(H.LoadFileContainer,'Position',H.LoadDat.Position+[80 0 100 0],'HorizontalAlignment','Left','Enable','inactive');
H.LoadIrf = CreatePushButton(H.LoadFileContainer,'Position',H.LoadDat.Position+[0 20 0 0],'String','Load irf file','Callback',{@GetFilePath,'irf'});
H.DispIrfFilePath = CreateEdit(H.LoadFileContainer,'Position',H.LoadIrf.Position+[80 0 100 0],'HorizontalAlignment','Left','Enable','inactive');
H.LoadTRSSet = CreatePushButton(H.LoadFileContainer,'Position',H.LoadIrf.Position+[0 20 0 0],'String','Load TRS set file','Callback',{@GetFilePath,'trs'});
H.DispTRSSetFilePath = CreateEdit(H.LoadFileContainer,'Position',H.LoadTRSSet.Position+[80 0 100 0],'HorizontalAlignment','Left','Enable','inactive');
H.ReadFitFile = CreatePushButton(MFH,'String','Read fit file','Callback',{@ReadFitData});
H.PlotRawScan = CreatePushButton(MFH,'Position',H.ReadFitFile.Position+[0 20 20 0],'String','Plot raw scan','Callback',{@PlotScan});
H.OpenGatePage = CreatePushButton(MFH,'Position',H.PlotRawScan.Position+[0 20 0 0],'String','Open gate page','Callback',{@OpenGatePage});
H.SumChannelsRawDatFile = CreatePushButton(MFH,'Position',H.OpenGatePage.Position+[0 20 40 0],'String','Sum channel raw scan','Callback',{@SumChannels});
H.ListFigures = CreateListBox(MFH,'Position',[40 560 280 100],'CallBack',{@OpenSelectedFigure});

guidata(MFH,H)


