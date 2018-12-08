function Wave = CalcReferenceGate(Roi,Irf,MFH)
[~,FileName,~] = fileparts(MFH.UserData.DispDatFilePath.String);
RefCurve = MFH.UserData.GateCurveReference.CurveReference;
Factor = MFH.UserData.CompiledHeaderData.McaFactor;
numwave = length(Roi(:,1));
numgate = str2double(MFH.UserData.NumGate.String);
fractfirst = str2double(MFH.UserData.FractFirst.String);
fractlast = str2double(MFH.UserData.FractLast.String);
Wavelengths = MFH.UserData.Wavelengths;
if fractfirst>=0
    firstdir = 'last';
else
    firstdir = 'first';
end
if fractlast>=0
    lastdir = 'last';
else
    lastdir = 'first';
end
fractlast = abs(fractlast);fractfirst = abs(fractfirst);
FH = findobj('Type','figure','-and','Name',['Gate plots - ' FileName]);
if ~isempty(FH)
    figure(FH);
else
    FH=figure('NumberTitle','off','Name',['Gate plots - ' FileName]);
end
nSub = numSubplots(numwave);
subH = subplot1(nSub(1),nSub(2),'XTickL','all');
for iw = 1:numwave
    Wave(iw).Roi = Roi(iw,1):Roi(iw,2);
    Wave(iw).RefCurve = RefCurve(Wave(iw).Roi); %#ok<*AGROW>
    Wave(iw).IrfCurve = Irf(Wave(iw).Roi);
    [~,MaxIrfPos]=max(Wave(iw).IrfCurve);
    Wave(iw).MaxIrfPos =MaxIrfPos;
    Wave(iw).AlignedRefCurve = zeros(size(Wave(iw).RefCurve));
    Wave(iw).AlignedRefCurve(Wave(iw).MaxIrfPos:end) = Wave(iw).RefCurve(Wave(iw).MaxIrfPos:end);
    Wave(iw).NormRefCurve = Wave(iw).AlignedRefCurve./max(Wave(iw).AlignedRefCurve);
    Wave(iw).NormIrfCurve = Wave(iw).IrfCurve./max(Wave(iw).IrfCurve);
    Wave(iw).FirstIndx = find(Wave(iw).NormRefCurve>=fractfirst,1,firstdir);
    Wave(iw).LastIndx = find(Wave(iw).NormRefCurve>=fractlast,1,lastdir);
    Wave(iw).Range = Wave(iw).FirstIndx:Wave(iw).LastIndx;
    Wave(iw).RangedCurve = zeros(size(Wave(iw).RefCurve));
    Wave(iw).Wavelengths = Wavelengths;
    Wave(iw).RangedCurve(Wave(iw).Range) = Wave(iw).AlignedRefCurve(Wave(iw).Range);
    Wave(iw).TemporalRange = Wave(iw).Range.*Factor;
    subplot1(iw);
    semilogy(subH(iw),[Wave(iw).NormRefCurve Wave(iw).NormIrfCurve Wave(iw).RangedCurve./max(Wave(iw).RangedCurve)])
    xlim([max(0,Wave(iw).FirstIndx-10) min(numel(Wave(iw).RefCurve),Wave(iw).LastIndx+10)])
    %     vline(Wave(iw).FirstIndx);
    %     vline(Wave(iw).LastIndx)
    title(num2str(Wavelengths(iw)));
    Wave(iw).Gate = CalcGate(Wave(iw).RangedCurve,Wave(iw).FirstIndx,Wave(iw).LastIndx,numgate);
end
delete(subH(iw+1:end))
MHF.UserData.GateCurveReference.Wave = Wave;
    function Gate=CalcGate(Curve,FirstIndx,~,NumGate)
        Counts = sum(Curve);
        CountsPerGate = Counts/NumGate;
        lastbin = FirstIndx; %firstbin = FirstIndx;
        %         figure(99);
        %         semilogy(Curve)
        for ig = 1:NumGate
            partialcounts = 0; ib = lastbin; firstbin = lastbin;
            while partialcounts<=CountsPerGate && ib<=numel(Curve)
                partialcounts = sum(Curve(firstbin:ib));
                ib = ib + 1;
            end
            lastbin = ib;
            Gate(ig).Counts = partialcounts;
            Gate(ig).Roi = [firstbin lastbin-1];
            if ~(Gate(ig).Roi(1)>=numel(Curve))
                vline(Gate(ig).Roi(1),'r:',num2str(ig),'percy',0.8);
                vline(Gate(ig).Roi(2));
            end
            Gate(ig).TemporalInterval = (Gate(ig).Roi-FirstIndx).*Factor;
            if firstbin>numel(Curve), firstbin = numel(Curve);end
            if lastbin>numel(Curve), lastbin = numel(Curve);end
        end
    end
end