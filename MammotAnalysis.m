%InitScript
MFH = figure('Name','Main panel','MenuBar','none','Toolbar','none','NumberTitle','off','CreateFcn','run(''./utilities/InstallMammotAnalysis.m'');','WindowState','maximized'); %MFH.Units = 'normalized';
MFH.UserData.Name = MFH.Name;
MFH.UserData.Wavelengths =[635 680 785 905 933 975 1060];
MFH.CloseRequestFcn = {@CloseMainFigure,MFH};
%MFH.SizeChangedFcn = {@ResizeMainFigure,MFH};
MFH.UserData.LoadFileContainer = CreateContainer(MFH,'Title','Load files','OuterPosition',[0.02 0.80 0.2 0.2]);%,'BorderType','none');
MFH.UserData.LoadFit = CreatePushButton(MFH.UserData.LoadFileContainer,'String','Load fit file',...
    'Units','normalized','Position',[0 0 0.2 1/5],'Callback',{@GetFilePath,'fit',MFH});
MFH.UserData.DispFitFilePath = CreateEdit(MFH.UserData.LoadFileContainer,'Units','normalized',...
    'Position',MFH.UserData.LoadFit.Position+[0.25 0 0.30 0],'HorizontalAlignment','Left','Enable','on');
MFH.UserData.LoadDat = CreatePushButton(MFH.UserData.LoadFileContainer,'Units','normalized',...
    'Position',MFH.UserData.LoadFit.Position+[0 1/5 0 0],'String','Load dat file','Callback',{@GetFilePath,'dat',MFH});
MFH.UserData.DispDatFilePath = CreateEdit(MFH.UserData.LoadFileContainer,'Units','normalized',...
    'Position',MFH.UserData.LoadDat.Position+[0.25 0 0.30 0],'HorizontalAlignment','Left','Enable','on');
MFH.UserData.LoadIrf = CreatePushButton(MFH.UserData.LoadFileContainer,'Units','normalized',...
    'Position',MFH.UserData.LoadDat.Position+[0 1/5 0 0],'String','Load irf file','Callback',{@GetFilePath,'irf',MFH});
MFH.UserData.DispIrfFilePath = CreateEdit(MFH.UserData.LoadFileContainer,'units','normalized',...
    'Position',MFH.UserData.LoadIrf.Position+[0.25 0 0.3 0],'HorizontalAlignment','Left','Enable','on');
MFH.UserData.LoadTRSSet = CreatePushButton(MFH.UserData.LoadFileContainer,'units','normalized',...
    'Position',MFH.UserData.LoadIrf.Position+[0 1/5 0 0],'String','Load TRS set file','Callback',{@GetFilePath,'trs',MFH});
MFH.UserData.DispTRSSetFilePath = CreateEdit(MFH.UserData.LoadFileContainer,'Units','normalized',...
    'Position',MFH.UserData.LoadTRSSet.Position+[0.25 0 0.3 0],'HorizontalAlignment','Left','Enable','on');
MFH.UserData.LoadSpectra = CreatePushButton(MFH.UserData.LoadFileContainer,'units','normalized',...
    'Position',MFH.UserData.LoadTRSSet.Position+[0 1/5 0 0],'String','Load spectra file','Callback',{@GetFilePath,'spectra',MFH});
MFH.UserData.DispSpectraFilePath = CreateEdit(MFH.UserData.LoadFileContainer,'Units','normalized',...
    'Position',MFH.UserData.LoadSpectra.Position+[0.25 0 0.3 0],'HorizontalAlignment','Left','Enable','on');
MFH.UserData.ListFiguresContainer = CreateContainer(MFH,...
    'OuterPosition',[0.02 0.37 0.2 0.40],'Title','Figure list');
MFH.UserData.ListFigures = CreateListBox(MFH.UserData.ListFiguresContainer,...
    'Units','normalized','Position',[0 0 1 1],'CallBack',{@OpenSelectedFigure});
MFH.UserData.MainActionsContainer = CreateContainer(MFH,'Title','Main actions',...
    'OuterPosition',[0.25 0.85 0.2 0.15]);%,'BorderType','none');
MFH.UserData.ReadFitFile = CreatePushButton(MFH.UserData.MainActionsContainer,'String','Read fit file',...
    'Units','normalized','Position',[0 0 0.2 1/4],'Callback',{@ReadFitData,MFH});
MFH.UserData.PlotRawScan = CreatePushButton(MFH.UserData.MainActionsContainer,'String','Plot raw scan',...
    'Units','normalized','Position',MFH.UserData.ReadFitFile.Position+[0 1/4 0.05 0],'Callback',{@PlotScan,MFH});
MFH.UserData.SumChannelsRawDatFile = CreatePushButton(MFH.UserData.MainActionsContainer,'String','Sum channel raw scan',...
    'Units','normalized','Position',MFH.UserData.PlotRawScan.Position+[0 1/4 0.15 0],'Callback',{@SumChannels,MFH});
MFH.UserData.ClearAll = CreatePushButton(MFH.UserData.MainActionsContainer,'String','Clear All',...
    'Units','normalized','Position',MFH.UserData.SumChannelsRawDatFile.Position+[0 1/4 0.05 0],'Callback',{@ClearAll,MFH});
MFH.UserData.EnableGatesPanel = CreateCheckBox(MFH.UserData.MainActionsContainer,'String','Enable gates panel',...
    'Units','normalized','Position',MFH.UserData.PlotRawScan.Position+[0.6 0 0.2 0],'Callback',{@EnableGatePanel,MFH});
MFH.UserData.OnlinePlot = CreateCheckBox(MFH.UserData.MainActionsContainer,'String','Online plot',...
    'Units','normalized','Position',MFH.UserData.PlotRawScan.Position+[0.3 0 0.005 0]);
MFH.UserData.GateContainer = CreateContainer(MFH,'Title','Gates',...
    'OuterPosition',[0.48 0.85 0.25 0.15],'Visible','off');%,'BorderType','none');
MFH.UserData.SelectReferenceArea = CreatePushButton(MFH.UserData.GateContainer,'String','Select reference area',...
    'Units','normalized','Position',[0 0 0.3 1/4],'Visible','on','Callback',{@SelectReferenceArea,MFH});
MFH.UserData.NumGate = CreateEdit(MFH.UserData.GateContainer,'Units','normalized',...
    'Position',MFH.UserData.SelectReferenceArea.Position+[0 1/4 -0.2 0],'String','10','HorizontalAlignment','Left','Callback',{@SetEditValue,'numgate'});
MFH.UserData.FractFirst = CreateEdit(MFH.UserData.GateContainer,'Units','normalized',...
    'Position',MFH.UserData.NumGate.Position+[0 1/4 0 0],'String','-0.9','HorizontalAlignment','Left','Callback',{@SetEditValue,'fractfirst'});
MFH.UserData.FractLast = CreateEdit(MFH.UserData.GateContainer,'Units','normalized',...
    'Position',MFH.UserData.FractFirst.Position+[0 1/4 0 0],'String','0.1','HorizontalAlignment','Left','Callback',{@SetEditValue,'fractlast'});
MFH.UserData.TextNumGate = CreateText(MFH.UserData.GateContainer,'Units','normalized',...
    'Position',MFH.UserData.NumGate.Position+[0.11 0 0.05 0],'String','Num gates','HorizontalAlignment','Left');
MFH.UserData.TextFractFirst = CreateText(MFH.UserData.GateContainer,'Units','normalized',...
    'Position',MFH.UserData.TextNumGate.Position+[0 1/4 0 0],'String','Fract first','HorizontalAlignment','Left');
MFH.UserData.TextFractLast = CreateText(MFH.UserData.GateContainer,'Units','normalized',...
    'Position',MFH.UserData.TextFractFirst.Position+[0 1/4 0 0],'String','Fract last','HorizontalAlignment','Left');
MFH.UserData.ReportContainer = CreateContainer(MFH,...
    'Title','Create report','OuterPosition',[0.25 0.3 0.2 0.5]);%,'BorderType','none');
MFH.UserData.Report = CreateEdit(MFH.UserData.ReportContainer,...
    'Units','normalized','OuterPosition',[0 0 1 0.85],'HorizontalAlignment','left','Max',2,'FontSize',10);
MFH.UserData.SaveReport = CreatePushButton(MFH.UserData.ReportContainer,'String','Save',...
    'Units','normalized','Position',[0 0.9 0.2 0.1],'Callback',{@SaveReport,MFH});
MFH.UserData.DefaultViewContainer = CreateContainer(MFH,...
    'Title','Default view','OuterPosition',[0.02 0.10 0.20 0.25]);%,'BorderType','none');
MFH.UserData.DefaultViewAxes = CreateAxes(MFH.UserData.DefaultViewContainer,...
    'Units','normalized','Position',[0.1 0.1 0.85 0.75],'CreateFcn',{@CreateDefaultView,MFH});
MFH.UserData.RotateDefaultView = CreatePushButton(MFH.UserData.DefaultViewContainer,...
    'String','Rotate','Units','normalized','Position',[0 0.9 0.3 0.1],'Callback',{@RotateDefaultView,MFH.UserData.DefaultViewAxes});
MFH.UserData.CompareContainer = CreateContainer(MFH,...
    'Title','Compare','OuterPosition',[0.47 0.05 0.5 0.75],'CreateFcn',{@CreateCompareAxes,MFH});%,'BorderType','none');