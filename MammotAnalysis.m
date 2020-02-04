clear('MainPanel'); close all force
run('.\utilities\Installer.m');
MainPanel = mfigure('Tag','MainPanel','Name','Main panel','MenuBar','none','Toolbar','none','NumberTitle','off','WindowState','maximized','Units','normalized','Category','MainPanel');
if ~isfile('.\Settings\sett.mat')
    MainPanel.Data.BkgFirst = 180;
    MainPanel.Data.BkgLast = 190;
    MainPanel.Data.FractFirst = -0.9;
    MainPanel.Data.FractLast = 0.1;
    MainPanel.Data.NumGates = 10;
else
    load('.\Settings\sett.mat','Data');
    MainPanel.Data = Data;
    clear Data;
end
MainPanel.Data.MinCountRateTresh = 0;
MainPanel.Data.MedianPercentageTreshold = (1-0.05);
MainPanel.Data.CalcWidthLevel = 0.5;
MainPanel.Figure.CloseRequestFcn = @MainPanel.Exit;
MainPanel.Graphical.LoadFileContainer = uipanel(MainPanel.Figure,'Title','Load files','Units','normalized','OuterPosition',[0.02 0.80 0.2 0.2],...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'LoadFileContainer'));
MainPanel.Graphical.LoadFit = uicontrol(MainPanel.Graphical.LoadFileContainer,'Style','pushbutton','String','Load FIT file',...
    'Units','normalized','Position',[0 0 0.23 1/5],'Callback',{@GetFilePath,'fit'},...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'LoadFit'));
MainPanel.Graphical.DispFitFilePath = uicontrol(MainPanel.Graphical.LoadFileContainer,'Style','edit','Units','normalized',...
    'Position',MainPanel.Graphical.LoadFit.Position+[0.25 0 0.50 0],'HorizontalAlignment','Left',...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'DispFitFilePath'));
MainPanel.Graphical.LoadDat = uicontrol(MainPanel.Graphical.LoadFileContainer,'Style','pushbutton','String','Load DAT file',...
    'Units','normalized','Position',MainPanel.Graphical.LoadFit.Position+[0 1/5 0 0],'Callback',{@GetFilePath,'dat'},...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'LoadDat'));
MainPanel.Graphical.DispDatFilePath = uicontrol(MainPanel.Graphical.LoadFileContainer,'Style','edit','Units','normalized',...
    'Position',MainPanel.Graphical.LoadDat.Position+[0.25 0 0.50 0],'HorizontalAlignment','Left',...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'DispDatFilePath'));
MainPanel.Graphical.LoadIrf = uicontrol(MainPanel.Graphical.LoadFileContainer,'Style','pushbutton','String','Load IRF file',...
    'Units','normalized','Position',MainPanel.Graphical.LoadDat.Position+[0 1/5 0 0],'Callback',{@GetFilePath,'irf'},...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'LoadIrf'));
MainPanel.Graphical.DispIrfFilePath = uicontrol(MainPanel.Graphical.LoadFileContainer,'Style','edit','Units','normalized',...
    'Position',MainPanel.Graphical.LoadIrf.Position+[0.25 0 0.50 0],'HorizontalAlignment','Left',...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'DispIrfFilePath'));
MainPanel.Graphical.LoadTRSSet = uicontrol(MainPanel.Graphical.LoadFileContainer,'Style','pushbutton','String','Load TRS file',...
    'Units','normalized','Position',MainPanel.Graphical.LoadIrf.Position+[0 1/5 0 0],'Callback',{@GetFilePath,'trs'},...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'LoadTRSSet'));
MainPanel.Graphical.DispTRSSetFilePath = uicontrol(MainPanel.Graphical.LoadFileContainer,'Style','edit','Units','normalized',...
    'Position',MainPanel.Graphical.LoadTRSSet.Position+[0.25 0 0.50 0],'HorizontalAlignment','Left',...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'DispTRSFilePath'));
MainPanel.Graphical.LoadSpectra = uicontrol(MainPanel.Graphical.LoadFileContainer,'Style','pushbutton','units','normalized',...
    'Position',MainPanel.Graphical.LoadTRSSet.Position+[0 1/5 0 0],'String','Load SPE file','Callback',{@GetFilePath,'spe'},...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'LoadSpectra'));
MainPanel.Graphical.DispSpeFilePath = uicontrol(MainPanel.Graphical.LoadFileContainer,'Style','edit','Units','normalized',...
    'Position',MainPanel.Graphical.LoadSpectra.Position+[0.25 0 0.50 0],'HorizontalAlignment','Left',...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'DispSpeFilePath'));
MainPanel.Graphical.MainActionsContainer = uipanel(MainPanel.Figure,'Title','Main actions','OuterPosition',[0.25 0.80 0.2 0.2],...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'MainActionsContainer'));
MainPanel.Graphical.ReadFitFile = uicontrol(MainPanel.Graphical.MainActionsContainer,'Style','pushbutton','String','Read fit file',...
    'Units','normalized','Position',[0 0 0.2 1/5],'Callback',{@ReadFitData,MainPanel},...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'ReadFitFile'));
MainPanel.Graphical.PlotRawScan = uicontrol(MainPanel.Graphical.MainActionsContainer,'Style','pushbutton','String','Plot scan',...
    'Units','normalized','Position',MainPanel.Graphical.ReadFitFile.Position+[0 1/5 0.05 0],'Callback',{@PlotScan,MainPanel},...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'PlotRawScan'));
MainPanel.Graphical.PlotIrf = uicontrol(MainPanel.Graphical.MainActionsContainer,'Style','pushbutton','String','Plot Irf',...
    'Units','normalized','Position',MainPanel.Graphical.PlotRawScan.Position+[0 1/5 0 0],'Callback',{@PlotIrf,MainPanel},...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'PlotIrf'));
MainPanel.Graphical.SumChannelsRawDatFile = uicontrol(MainPanel.Graphical.MainActionsContainer,'Style','pushbutton','String','Sum channel raw scan',...
    'Units','normalized','Position',MainPanel.Graphical.PlotIrf.Position+[0 1/5 0.15 0],'Callback',{@SumChannels,MainPanel},...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'SumChannelsRawDatFile'));
% MainPanel.Graphical.ClearAll = uicontrol(MainPanel.Graphical.MainActionsContainer,'Style','pushbutton','String','Clear All',...
%     'Units','normalized','Position',MainPanel.Graphical.SumChannelsRawDatFile.Position+[0 1/5 0.05 0],'Callback',{@ClearAll,MainPanel},...
%     'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'ClearAll'));
MainPanel.Graphical.OnlinePlot = uicontrol(MainPanel.Graphical.MainActionsContainer,'Style','checkbox','String','Online plot',...
    'Units','normalized','Position',MainPanel.Graphical.PlotRawScan.Position+[0.50 0 0.005 0],...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'OnlinePlot'));
MainPanel.Graphical.ParamsContainer = uipanel(MainPanel.Figure,'Title','Params','Units','normalized','OuterPosition',[0.58 0.9 0.12 0.10],...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'ParamsContainer'));
MainPanel.Graphical.FractLast = uicontrol(MainPanel.Graphical.ParamsContainer,'Style','edit','String',num2str(MainPanel.Data.FractLast),...
    'Units','normalized','Position',[0 0 1/6 0.5],'HorizontalAlignment','Left',...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'FractLast'));
MainPanel.Graphical.FractFirst = uicontrol(MainPanel.Graphical.ParamsContainer,'Style','edit','String',num2str(MainPanel.Data.FractFirst),...
    'Units','normalized','Position',MainPanel.Graphical.FractLast.Position+[0 1/2 0 0],'HorizontalAlignment','Left',...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'FractFirst'));
MainPanel.Graphical.TextFractFirst = uicontrol(MainPanel.Graphical.ParamsContainer,'Style','text','String','Fract first',...
    'Units','normalized','Position',MainPanel.Graphical.FractFirst.Position+[1/5 -0.1 0 0],'HorizontalAlignment','Left',...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'TextFractFirst'));
MainPanel.Graphical.TextFractLast = uicontrol(MainPanel.Graphical.ParamsContainer,'Style','text','String','Fract last',...
    'Units','normalized','Position',MainPanel.Graphical.FractLast.Position+[1/5 -0.1 0 0],'HorizontalAlignment','Left',...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'TextFractLast'));
MainPanel.Graphical.BkgLast = uicontrol(MainPanel.Graphical.ParamsContainer,'Style','edit','String',num2str(MainPanel.Data.BkgLast),...
    'Units','normalized','Position',[2/5-0.05 0 1/6 0.5],'HorizontalAlignment','Left',...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'BkgLast'));
MainPanel.Graphical.BkgFirst = uicontrol(MainPanel.Graphical.ParamsContainer,'Style','edit','String',num2str(MainPanel.Data.BkgFirst),...
    'Units','normalized','Position',MainPanel.Graphical.BkgLast.Position+[0 1/2 0 0],'HorizontalAlignment','Left',...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'BkgFirst'));
MainPanel.Graphical.TextBkgFirst = uicontrol(MainPanel.Graphical.ParamsContainer,'Style','text','String','Bkg first',...
    'Units','normalized','Position',MainPanel.Graphical.BkgFirst.Position+[1/5 -0.1 0 0],'HorizontalAlignment','Left',...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'TextBkgFirst'));
MainPanel.Graphical.TextBkgLast = uicontrol(MainPanel.Graphical.ParamsContainer,'Style','text','String','Bkg last',...
    'Units','normalized','Position',MainPanel.Graphical.BkgLast.Position+[1/5 -0.1 0 0],'HorizontalAlignment','Left',...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'TextBkgLast'));
MainPanel.Graphical.NumGates = uicontrol(MainPanel.Graphical.ParamsContainer,'Style','edit','String',num2str(MainPanel.Data.NumGates),...
    'Units','normalized','Position',[0.67 0 1/6 0.5],'String','10','HorizontalAlignment','Left');
MainPanel.Graphical.TextNumGate = uicontrol(MainPanel.Graphical.ParamsContainer,'Style','text','String','Num gates',...
    'Units','normalized','Position',MainPanel.Graphical.NumGates.Position+[1/5 -0.1 0 0],'HorizontalAlignment','Left',...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'TextNumGate'));


return
MainPanel.Graphical.ListFiguresContainer = CreateContainer(MainPanel.Figure,...
    'OuterPosition',[0.02 0.507 0.2 0.40],'Title','Figure list');
MainPanel.Graphical.ListFigures = CreateListBox(MainPanel.Graphical.ListFiguresContainer,...
    'Units','normalized','Position',[0 0 1 1],'CallBack',{@OpenSelectedFigure});
return
MainPanel.Graphical.GateContainer = uipanel(MainPanel.Figure,'Title','Gates','Units','normalized','OuterPosition',[0.48 0.90 0.08 0.1],...
    'Tag',strcat(MainPanel.Tag,MainPanel.spacer,'GateContainer'));
MainPanel.Graphical.SelectReferenceArea = CreatePushButton(MainPanel.Graphical.GateContainer,'String','Select reference area',...
    'Units','normalized','Position',[0 0 1 1/2],'Visible','on','Callback',{@SelectReferenceArea,MainPanel.Figure});
MainPanel.Graphical.NumGates = CreateEdit(MainPanel.Graphical.GateContainer,'Units','normalized',...
    'Position',MainPanel.Graphical.SelectReferenceArea.Position+[0 1/2 -3/4 0],'String','10','HorizontalAlignment','Left');
MainPanel.Graphical.TextNumGate = CreateText(MainPanel.Graphical.GateContainer,'Units','normalized',...
    'Position',MainPanel.Graphical.NumGates.Position+[1/4 0 0.05 0],'String','Num gates','HorizontalAlignment','Left');
MainPanel.Graphical.ReportContainer = CreateContainer(MainPanel.Figure,...
    'Title','Create report','OuterPosition',[0.25 0.50 0.2 0.5]);%,'BorderType','none');
MainPanel.Graphical.Report = CreateEdit(MainPanel.Graphical.ReportContainer,...
    'Units','normalized','OuterPosition',[0 0 1 0.85],'HorizontalAlignment','left','Max',2,'FontSize',10);
MainPanel.Graphical.SaveReport = CreatePushButton(MainPanel.Graphical.ReportContainer,'String','Save',...
    'Units','normalized','Position',[0 0.9 0.2 0.1],'Callback',{@SaveReport,MainPanel.Figure});
MainPanel.Graphical.DefaultViewContainer = CreateContainer(MainPanel.Figure,...
    'Title','Default view','OuterPosition',[0.02 0.10 0.20 0.25]);%,'BorderType','none');
MainPanel.Graphical.DefaultViewAxes = CreateAxes(MainPanel.Graphical.DefaultViewContainer,...
    'Units','normalized','Position',[0.1 0.1 0.85 0.75],'CreateFcn',{@CreateDefaultView,MainPanel.Figure});
MainPanel.Graphical.RotateDefaultView = CreatePushButton(MainPanel.Graphical.DefaultViewContainer,...
    'String','Rotate','Units','normalized','Position',[0 0.9 0.50 0.1],'Callback',{@RotateDefaultView,MainPanel.Graphical.DefaultViewAxes});