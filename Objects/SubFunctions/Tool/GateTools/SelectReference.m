function message = SelectReference(mtoolobj,toolname,nobjs,iobj)
persistent shape2copy
type = 'gate';
switch toolname{1}
    case 'shape'
        message = ApplyShape(mtoolobj,toolname{2},type,shape2copy);
        if nobjs>1 && iobj == 1
            shape2copy = mtoolobj.Roi(end).Shape;
        elseif iobj==nobjs
            shape2copy = [];
        end
        addlistener(mtoolobj.Roi(end).Shape,'ROIMoved',@(src,event)PickAreaOnImage(src,event,mtoolobj.Axes));
        PickAreaOnImage(mtoolobj.Roi(end).Shape,[],mtoolobj.Axes);
    case 'point'
        message = PickCurveOnImage(mtoolobj);
end
end
function PickData = PickAreaOnImage(shapeobj,~,maxesobj)
PickData = squeeze(maxesobj.Parent.Data.PickData);
PickData = PickData.*shapeobj.createMask;
PickData(PickData==0)=nan;
PickData = squeeze(mean(PickData,[1 2],'omitnan'));
mfigure('Name',['Average curve of ',maxesobj.Name,' for gate reference. ',maxesobj.Parent.Name],'Category','Gate reference');
numbin = size(PickData,1);
semilogy(1:numbin,PickData);
xlim([1 numbin]);
maxesobj.Parent.Data.ReferenceCurve = PickData;
end
function message = PickCurveOnImage(mtoolobj)
dch = datacursormode(mtoolobj.Parent.Figure);
datacursormode on
dch.DisplayStyle = 'window';
dch.UpdateFcn = {@PickCurve,mtoolobj.Parent};
message = 'Pick reference curve tool';
end
function output_txt=PickCurve(datacursorobj,~,mfigobj)
persistent PreviousParent
persistent Times
pos = datacursorobj.Position; cpos = pos(1); rpos = pos(2);
AxesNames = {mfigobj.Axes.Name};
maxesobj = mfigobj.Axes(strcmpi(AxesNames,datacursorobj.Parent.Title.String));
if isempty(PreviousParent)||isequal(PreviousParent,maxesobj)
    PreviousParent = maxesobj;
    Times = 1;
else
    if ~isequal(PreviousParent,maxesobj)
        if Times == 1
            Times = Times + 1;
            output_txt = {'Wait'};
            return;
        else
            Times = 1;
            PreviousParent = maxesobj;
        end
    end
end
MP = get(0, 'MonitorPositions');
if size(MP, 1) == 1  % Single monitor
    maxesobj.Parent.Figure.WindowState = 'normal';
end
mfigure('Name',['Average curve of ',maxesobj.Name,' for gate reference. ',maxesobj.Parent.Name],'Category','Gate reference');
PickData = squeeze(maxesobj.Parent.Data.PickData);
numbin = size(PickData,3);
semilogy(1:numbin,squeeze(PickData(rpos,cpos,:)));
xlim([1 numbin]);
ylim([1 max(PickData(:))]);
maxesobj.Parent.Show;
output_txt = [...
    {maxesobj.Name},...
    {strcat('X: ',num2str(round(cpos)))},...
    {strcat('Y: ',num2str(round(rpos)))},...
    {strcat('Z: ',num2str(PickData(rpos,cpos)))}];
maxesobj.Parent.Data.ReferenceCurve = squeeze(PickData(rpos,cpos,:));
end