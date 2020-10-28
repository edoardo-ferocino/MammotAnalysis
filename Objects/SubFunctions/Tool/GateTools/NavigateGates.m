function message = NavigateGates(mtoolobj)
Wave = mtoolobj.Parent.Data.Wave;
SetPushButtons(mtoolobj,Wave);
message = 'Navigate gates activated';
end

function SetPushButtons(mtoolobj,Wave)
lambda = regexpi(mtoolobj.Axes.Name,'(\d)+.\s','tokens');
lambda = str2double(cell2mat(lambda{1}));
SubID=find(mtoolobj.Parent.Wavelengths==lambda);
SubH = mtoolobj.Axes.axes;
ContainerH = uipanel(mtoolobj.Parent.Figure,'OuterPosition',[SubH.OuterPosition(1)+SubH.OuterPosition(3)/4 SubH.Position(2)+0.9*SubH.Position(4) 0.07 0.08]);
DecreasePushH = uicontrol(ContainerH,'Style','pushbutton','String','Decrease','Units','normalized',...
    'Position',[0 0 0.5 1/2],'Callback',{@Clicked,SubH,SubID,'down',Wave,mtoolobj});
uicontrol(ContainerH,'Style','pushbutton','String','Increase','Units','normalized',...
    'Position',DecreasePushH.Position+[0 1/2 0 0],'Callback',{@Clicked,SubH,SubID,'up',Wave,mtoolobj});
uicontrol(ContainerH,'Style','edit','String',num2str(Wave(SubID).DefaultGate),'Units','normalized',...
    'Position',DecreasePushH.Position+[DecreasePushH.Position(3) 0 0 0],'Callback',{@GotoPage,SubH,SubID,Wave,mtoolobj},'Tag','GateID');
uicontrol(ContainerH,'Style','text','String','Goto gate #','Units','normalized',...
    'Position',DecreasePushH.Position+[DecreasePushH.Position(3) 0.5 0 0]);
if ~isfield(mtoolobj.Parent.Graphicals,'NaviGates')
    mtoolobj.Parent.Graphicals.NaviGates = ContainerH;
else
    mtoolobj.Parent.Graphicals.NaviGates = vertcat(mtoolobj.Parent.Graphicals.NaviGates,ContainerH);
end
SubH.UserData.WaveID = SubID;
SubH.UserData.MinVal = 1;SubH.UserData.MaxVal = Wave(SubID).NumGate;
SubH.UserData.ActualGateVal = Wave(SubID).DefaultGate;
end
function Clicked(src,~,SubH,SubID,type,Wave,mtoolobj)
if strcmpi(type,'up')
    delta = 1;
    if SubH.UserData.ActualGateVal >=SubH.UserData.MaxVal, delta = 0; end
else
    delta = -1;
    if SubH.UserData.ActualGateVal <=SubH.UserData.MinVal, delta = 0; end
end
if delta == 0, return, end
SubH.UserData.ActualGateVal = SubH.UserData.ActualGateVal+delta;
% needed if the user is too fast in clicking
if SubH.UserData.ActualGateVal>=SubH.UserData.MaxVal
    SubH.UserData.ActualGateVal = SubH.UserData.MaxVal;
end
if SubH.UserData.ActualGateVal<=SubH.UserData.MinVal
    SubH.UserData.ActualGateVal = SubH.UserData.MinVal;
end
PlotGatePage(Wave,SubH,SubID,SubH.UserData.ActualGateVal,mtoolobj);
ContH=ancestor(src,'uicontainer');
GateIDH=findobj(ContH,'Tag','GateID');
GateIDH.String = num2str(SubH.UserData.ActualGateVal);
end
function GotoPage(src,~,SubH,SubID,Wave,mtoolobj)
PageID = str2double(src.String);
SubH.UserData.ActualGateVal = PageID;
% needed if the user is too fast in clicking
if SubH.UserData.ActualGateVal>=SubH.UserData.MaxVal
    SubH.UserData.ActualGateVal = SubH.UserData.MaxVal;
end
if SubH.UserData.ActualGateVal<=SubH.UserData.MinVal
    SubH.UserData.ActualGateVal = SubH.UserData.MinVal;
end
PlotGatePage(Wave,SubH,SubID,SubH.UserData.ActualGateVal,mtoolobj);
end
