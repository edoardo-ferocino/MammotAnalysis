function message = ApplyReference(mtoolobj)
MPOBJ=mtoolobj.Parent.GetMainPanel;
if ~isfield(MPOBJ.Data,'DatFilePath')
    DisplayError('No data file','Please read the Irf file');
    return
end
mselectfigobj = mtoolobj.Parent.SelectMultipleFigures([],[],'select','AllChannels, all lambdas, bkg free IRF plot');%here, it selects only one compare figure
waitfor(mselectfigobj.Figure,'Visible','off');
if strcmpi(mselectfigobj.Data.ExitStatus,'Exit')
    return;
elseif strcmpi(mselectfigobj.Data.ExitStatus,'Ok')
    IrfFigObj = mselectfigobj.Data.SelectedFigure;
end
IrfFigObj.Selected = false;

mtoolobj.Parent.StartWait;
IrfCurve=IrfFigObj.Data.PickData;
RefCurve = mtoolobj.Parent.Data.ReferenceCurve;
Data = squeeze(mtoolobj.Parent.Data.PickData);
if any(isnan(IrfCurve(:)))||any(isnan(RefCurve(:)))||any(isnan(Data(:)))
    DisplayError('Encountered NaN values','Contact developer');
    return
end
[nr,nc,~]=size(Data);
InterpStep = 0.1;
Wavelengths = MPOBJ.Wavelengths;
NumGate = str2double(MPOBJ.Graphical.NumGates.String);
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

mfigobj=mfigure('Name','Gated reference curve','Category','Reference curve');
nSub=numSubplots(numel(mfigobj.Wavelengths));
tlh=tiledlayout(mfigobj.Figure,nSub(1),nSub(2),'Padding','none','TileSpacing','none');
Wave=struct.empty(numel(Wavelengths),0);
for iw = 1:numel(Wavelengths)
    Roi=TrsSet.Roi(iw,2)+1:TrsSet.Roi(iw,3)+1;
    Wave(iw).OverallLimits = [inf -inf];
    Wave(iw).NumGate = NumGate;
    Wave(iw).DefaultGate = 8;
    Wave(iw).Name = Wavelengths(iw);
    Wave(iw).Roi = Roi;
    Wave(iw).RefCurve = RefCurve(Roi);
    Wave(iw).Irf = IrfCurve(Roi);
    Wave(iw).Data = Data(:,:,Roi);
    Wave(iw).RefCurve = interp1(Wave(iw).Roi,Wave(iw).RefCurve,Wave(iw).Roi(1):InterpStep:Wave(iw).Roi(end));
    Wave(iw).Irf = interp1(Wave(iw).Roi,Wave(iw).Irf,Wave(iw).Roi(1):InterpStep:Wave(iw).Roi(end));
    for ic = 1:nc
        for ir = 1:nr
            Wave(iw).InterpData(ir,ic,:) = interp1(Wave(iw).Roi,squeeze(Wave(iw).Data(ir,ic,:)),Wave(iw).Roi(1):InterpStep:Wave(iw).Roi(end));
        end
    end
    [~,maxpos]=max(Wave(iw).Irf);
    Wave(iw).RefCurve = Wave(iw).RefCurve(maxpos:end);
    Wave(iw).InterpData=Wave(iw).InterpData(:,:,maxpos:end);
    nexttile(tlh);
    Wave(iw).GateRoi = CalcGates(Wave(iw).RefCurve,NumGate,Wave(iw).Name);
    for ig = 1:NumGate
        Wave(iw).Gate(ig).Curves = Wave(iw).InterpData(:,:,Wave(iw).GateRoi(ig,1):Wave(iw).GateRoi(ig,2));
        Wave(iw).Gate(ig).Data = sum(Wave(iw).Gate(ig).Curves,3);
        Wave(iw).Limits(ig,:) = GetPercentile(Wave(iw).Gate(ig).Data,[mtoolobj.Axes.LowPercentile mtoolobj.Axes.HighPercentile]);
    end
    Wave(iw).Limits = [min(Wave(iw).Limits(:,1)) max(Wave(iw).Limits(:,2))];
    Wave(iw).OverallLimits = [min(Wave(iw).Limits(1),Wave(iw).OverallLimits(1)) max(Wave(iw).Limits(2),Wave(iw).OverallLimits(2))];
end
mtoolobj.Parent.StopWait;
PlotGates(Wave,mtoolobj.Parent.Data.FileName);
message = 'Computed gates from reference';
end
function Roi = CalcGates(Curve,NumGate,Name)
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
        if ig==1
            semilogy(1:NumBin,Curve)
        end
        xline(last);
        hold on
        ig = ig +1;
    end
end
title(['\lambda = ',num2str(Name)])
hold off
Roi(2:end,:)=Roi(2:end,:)+1;

end