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
if nargout>1
    varargout{1} =  TotalReferenceMask;
end
maxesactvobj.CLim = GetPercentile(dataout,[maxesactvobj.LowPercentile maxesactvobj.HighPercentile]);
end