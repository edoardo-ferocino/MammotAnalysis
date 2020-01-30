function [dataout,varargout] = MedianMask(datain,maxesactvobj)
if isfield(maxesactvobj.Parent.Data,'TotalReferenceMask')
    TotalReferenceMask =  maxesactvobj.Parent.Data.TotalReferenceMask;
else
    mselectfigobj = maxesactvobj.Parent.SelectMultipleFigures([],[],'select');
    waitfor(mselectfigobj.Figure,'Visible','off');
    if strcmpi(mselectfigobj.Data.ExitStatu,'Exit')
        return;
    end
    allmfigobjs = mselectfigobj.GetAllFigs;
    if ~isfield(allmfigobjs(vertcat(allmfigobjs.Selected)).Data,'TotalReferenceMask')
        [~,TotalReferenceMask]=MedianMask(datain,maxesactvobj);
        allmfigobjs(vertcat(allmfigobjs.Selected)).Selected = false;
        allmfigobjs(vertcat(allmfigobjs.Selected)).DeselectAll;
    else
        TotalReferenceMask=allmfigobjs(vertcat(allmfigobjs.Selected)).Data.TotalReferenceMask;
    end
    maxesactvobj.Parent.Data.TotalReferenceMask = TotalReferenceMask;
end
dataout = TotalReferenceMask.*datain;
if nargout>1
    varargout{1} =  TotalReferenceMask;
end
maxesactvobj.CLim = GetPercentile(dataout,[maxesactvobj.LowPercentile maxesactvobj.HighPercentile]);
end