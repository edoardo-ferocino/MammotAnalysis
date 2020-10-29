function [dataout,varargout] = MedianMask(datain,maxesactvobj)
if isfield(maxesactvobj.Parent.Data,'TotalReferenceMask')
    TotalReferenceMask =  maxesactvobj.Parent.Data.TotalReferenceMask;
else
    mselectfigobj = maxesactvobj.Parent.SelectMultipleFigures([],[],'select','Any figure obtained from PlotScan');
    waitfor(mselectfigobj.Figure,'Visible','off');
    if strcmpi(mselectfigobj.Data.ExitStatus,'Exit')
        return;
    elseif strcmpi(mselectfigobj.Data.ExitStatus,'Ok')
        selfigmobj = mselectfigobj.Data.SelectedFigure;
    end
    if ~isfield(selfigmobj.Data,'TotalReferenceMask')
        selfigmobj.Selected = false;
        [~,TotalReferenceMask]=MedianMask(datain,maxesactvobj);
    else
        TotalReferenceMask=selfigmobj.Data.TotalReferenceMask;
        selfigmobj.Selected = false;
    end
    maxesactvobj.Parent.Data.TotalReferenceMask = TotalReferenceMask;
end
dataout = TotalReferenceMask.*datain;

if isfield(maxesactvobj.Parent.Data,'PickData')
    OrigPickData = maxesactvobj.Parent.Data.PickData;
    lambda = regexpi(maxesactvobj.Name,'\lambda\s=*\s(\d)+','tokens');
    channel = regexpi(maxesactvobj.Name,'Channel ([0-9]?)','tokens');
    if ~isempty(lambda)
        lambda=lambda{1};lambda=lambda{1};lambda=str2double(lambda);
        maxesactvobj.Parent.Data.PickData(maxesactvobj.Parent.Wavelengths==lambda).SummedChannelsData = TotalReferenceMask.*OrigPickData(maxesactvobj.Parent.Wavelengths==lambda).SummedChannelsData;
    elseif ~isempty(channel)
        channel=channel{1};channel=channel{1};channel=str2double(channel);
        maxesactvobj.Parent.Data.PickData(:,:,channel,:) = TotalReferenceMask.*OrigPickData(:,:,channel,:);
    else
        maxesactvobj.Parent.Data.PickData = TotalReferenceMask.*maxesactvobj.Parent.Data.PickData;
    end
end

if nargout>1
    varargout{1} =  TotalReferenceMask;
end
end