InitScript
MFH = FFS('Name','Main panel'); %MFH.Units = 'normalized';
H = guihandles(MFH);
H.MFH = MFH;
MFH.UserData.Name = MFH.Name;
addpath('./utilities');
MFH.CloseRequestFcn = {@CloseMainFigure};
H.LoadFileContainer = CreateContainer(MFH,'Title','Load files','OuterPosition',[0.02 0.85 0.2 0.15]);
MFH.UserData.LoadFileContainer = H.LoadFileContainer;
H.LoadFit = CreatePushButton(H.LoadFileContainer,'String','Load fit file','Callback',{@GetFilePath,'fit',MFH});
MFH.UserData.LoadFit = H.LoadFit;
H.DispFitFilePath = CreateEdit(H.LoadFileContainer,'Position',H.LoadFit.Position+[80 0 100 0],'HorizontalAlignment','Left','Enable','inactive');
MFH.UserData.DispFitFilePath = H.DispFitFilePath;
H.LoadDat = CreatePushButton(H.LoadFileContainer,'Position',H.LoadFit.Position+[0 20 0 0],'String','Load dat file','Callback',{@GetFilePath,'dat',MFH});
MFH.UserData.LoadDat = H.LoadDat;
H.DispDatFilePath = CreateEdit(H.LoadFileContainer,'Position',H.LoadDat.Position+[80 0 100 0],'HorizontalAlignment','Left','Enable','inactive');
MFH.UserData.DispDatFilePath = H.DispDatFilePath;
H.LoadIrf = CreatePushButton(H.LoadFileContainer,'Position',H.LoadDat.Position+[0 20 0 0],'String','Load irf file','Callback',{@GetFilePath,'irf',MFH});
MFH.UserData.LoadIrf = H.LoadIrf;
H.DispIrfFilePath = CreateEdit(H.LoadFileContainer,'Position',H.LoadIrf.Position+[80 0 100 0],'HorizontalAlignment','Left','Enable','inactive');
MFH.UserData.DispIrfFilePath = H.DispIrfFilePath;
H.LoadTRSSet = CreatePushButton(H.LoadFileContainer,'Position',H.LoadIrf.Position+[0 20 0 0],'String','Load TRS set file','Callback',{@GetFilePath,'trs',MFH});
MFH.UserData.LoadTRSSet = H.LoadTRSSet;
H.DispTRSSetFilePath = CreateEdit(H.LoadFileContainer,'Position',H.LoadTRSSet.Position+[80 0 100 0],'HorizontalAlignment','Left','Enable','inactive');
MFH.UserData.DispTRSSetFilePath = H.DispTRSSetFilePath;
H.ReadFitFile = CreatePushButton(MFH,'String','Read fit file','Callback',{@ReadFitData,MFH});
MFH.UserData.ReadFitFile = H.ReadFitFile;
H.PlotRawScan = CreatePushButton(MFH,'Position',H.ReadFitFile.Position+[0 20 20 0],'String','Plot raw scan','Callback',{@PlotScan,MFH});
MFH.UserData.PlotRawScan = H.PlotRawScan;
H.OpenGatePage = CreatePushButton(MFH,'Position',H.PlotRawScan.Position+[0 20 0 0],'String','Open gate page','Callback',{@OpenGatePage});
MFH.UserData.OpenGatePage = H.OpenGatePage;
H.SumChannelsRawDatFile = CreatePushButton(MFH,'Position',H.OpenGatePage.Position+[0 20 40 0],'String','Sum channel raw scan','Callback',{@SumChannels,MFH});
MFH.UserData.SumChannelsRawDatFile = H.SumChannelsRawDatFile;
H.ListFigures = CreateListBox(MFH,'Position',[40 560 280 100],'CallBack',{@OpenSelectedFigure});
MFH.UserData.ListFigures = H.ListFigures;

guidata(MFH,H)


