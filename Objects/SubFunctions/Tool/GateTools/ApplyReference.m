function message = ApplyReference(mtoolobj)
MPOBJ=mtoolobj.Parent.GetMainPanel;
if ~isfield(MPOBJ.Data,'DatFilePath')
    DisplayError('No data file','Please read the Irf file');
    return
end
mselectfigobj = mtoolobj.Parent.SelectMultipleFigures([],[],'select','AllChannels, all lambdas, bkg free IRF plot');%here, it selects only one compare figure
waitfor(mselectfigobj.Figure,'Visible','off');
if strcmpi(mselectfigobj.Data.ExitStatus,'Exit'),return;end
allmfigobjs = mselectfigobj.GetAllFigs;IrfFigObj=allmfigobjs(vertcat(allmfigobjs.Selected));
IrfFigObj.Selected = false;

IrfCurve=IrfFigObj.Data.PickData;
RefCurve = mtoolobj.Parent.Data.ReferenceCurve;
InterpStep = 0.1;
Wavelengths = MPOBJ.Wavelengths;
NumGate = str2double(MPOBJ.Graphical.NumGate.String);
NumBin = size(RefCurve,1);
if isfield(MPOBJ.Data,'TRSSetFilePath')
    TrsSet = TRSread(MPOBJ.Data.TRSSetFilePath);
else
    TrsSet.Roi = zeros(numel(Wavelengths),3);
    limits = round(linspace(0,NumBin-1,numel(Wavelengths)+1));
    for ir = 1:numel(Wavelengths)
        TrsSet.Roi(ir,2) = limits(ir);
        TrsSet.Roi(ir,3) = limits(ir+1);
    end
end
for iw = 1:numel(Wavelengths)
    Roi=TrsSet.Roi(iw,2)+1:TrsSet.Roi(iw,3)+1;
    Wave(iw).Roi = Roi;
    Wave(iw).RefCurve = RefCurve(Roi); %#ok<*AGROW>
    Wave(iw).RefCurve = interp1(Wave(iw).Roi,Wave(iw).RefCurve,Wave(iw).Roi(1):InterpStep:Wave(iw).Roi(end));
    Wave(iw).Irf = IrfCurve(Roi); %#ok<*AGROW>
    Wave(iw).Irf = interp1(Wave(iw).Roi,Wave(iw).Irf,Wave(iw).Roi(1):InterpStep:Wave(iw).Roi(end));
    [~,maxpos]=max(Wave(iw).Irf);
    Wave(iw).RefCurve = Wave(iw).RefCurve(maxpos:end);
    Wave(iw).GateRoi = CalcGates(Wave(iw).RefCurve,NumGate);
end
message = 'done';
end
function Roi = CalcGates(Curve,NumGate)
NumPh = sum(Curve);
NumPhPerGate = NumPh/NumGate;
NumBin = size(Curve,2);
first = 1;ig=1;
Roi = zeros(NumGate,2);
for ich=1:NumBin
    if logical(sum(Curve(first:ich)) >= NumPhPerGate)||(logical(ich == NumBin)&&logical(ig<=NumGate))
        last = ich;
        Roi(ig,:) = [first last];
        first = last;
        figure(33);
        if ig==1
            semilogy(1:NumBin,Curve)
        end
        xline(last)
        hold on
        ig = ig +1;
    end
end


end