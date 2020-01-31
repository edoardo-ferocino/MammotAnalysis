function message = ApplyReference(mtoolobj)
MPOBJ=mtoolobj.Parent.GetMainPanel;
if ~isfield(MPOBJ.Data,'DatFilePath')
    DisplayError('No data file','Please read the Irf file');
    return
end
mselectfigobj = mtoolobj.Parent.SelectMultipleFigures([],[],'select','AllChannels, all lambdas, bkg free IRF plot');%here, it selects only one compare figure
waitfor(mselectfigobj.Figure,'Visible','off');
if strcmpi(mselectfigobj.Data.ExitStatus,'Exit'),return;end
allmfigobjs = mselectfigobj.GetAllFigs;
IrfFigObj=allmfigobjs(vertcat(allmfigobjs.Selected));
IrfCurve=IrfFigObj.Data.PickData';
RefCurve = mtoolobj.Parent.Data.ReferenceCurve;

end