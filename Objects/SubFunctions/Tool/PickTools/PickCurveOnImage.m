function message = PickCurveOnImage(mtoolobj)
dch = datacursormode(mtoolobj.Parent.Figure);
datacursormode on
dch.DisplayStyle = 'window';
dch.UpdateFcn = {@PickCurve,mtoolobj.Parent};
message = 'Pick Curve applied';
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
mfigobj=mfigure('Name',['Pick curve of ',maxesobj.Name,'. ',maxesobj.Parent.Name],'Category','Pick Curve');
Data = maxesobj.ImageData;
PickData = maxesobj.Parent.Data.PickData;
lambda = regexp(maxesobj.Name,'\lambda\s=*\s(\d)+','tokens');
channel = regexp(maxesobj.Name,'Channel ([0-9]?)','tokens');
if ~isempty(lambda)
    lambda=lambda{1};lambda=lambda{1};lambda=str2double(lambda);
    PickData = PickData(mfigobj.Wavelengths==lambda).SummedChannelsData;
elseif ~isempty(channel)
    channel=channel{1};channel=channel{1};channel=str2double(channel);
    PickData = squeeze(PickData(:,:,channel,:));
else
    PickData = squeeze(PickData);
end
numbin = size(PickData,3);
output_txt = [...
    {strcat('X: ',num2str(round(cpos)))},...
    {strcat('Y: ',num2str(round(rpos)))},...
    {strcat('Z: ',num2str(Data(rpos,cpos)))}];
semilogy(1:numbin,squeeze(PickData(rpos,cpos,:)));
xlim([1 numbin]);
ylim([1 max(PickData(:))]);
maxesobj.Parent.Show;
end