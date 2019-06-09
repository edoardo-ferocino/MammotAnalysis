function Wave = CalcReferenceGate(~,~,ParentFH,MFH)
Bkg = mean(ParentFH.UserData.Gate.CurveReference.Curve(str2double(MFH.UserData.BkgFirst.String):str2double(MFH.UserData.BkgLast.String)));
RefCurve = ParentFH.UserData.Gate.CurveReference.Curve - Bkg;
Bkg = mean(ParentFH.UserData.ActualIrfData(str2double(MFH.UserData.BkgFirst.String):str2double(MFH.UserData.BkgLast.String)));
Irf = ParentFH.UserData.ActualIrfData - Bkg;
Factor = ParentFH.UserData.CompiledHeaderData.McaFactor;
InterpStep = 0.1;
numwave = numel(MFH.UserData.Wavelengths);
numgate = str2double(MFH.UserData.NumGate.String);
Wavelengths = MFH.UserData.Wavelengths;
Roi = ParentFH.UserData.TrsSet.Roi(1:numwave,2:3)+1;
[~,FileName]=fileparts(ParentFH.UserData.DatFilePath);
FH=CreateOrFindFig(['Reference Gate plots - ' FileName],'WindowState','maximized');
nSub = numSubplots(numwave);
subH = subplot1(nSub(1),nSub(2),'XTickL','all','Gap',[0.05 0.1]);
for iw = 1:numwave
    Wave(iw).Roi.First = Roi(iw,1);
    Wave(iw).Roi.Last = Roi(iw,2);
    Wave(iw).Roi.Array = Wave(iw).Roi.First:Wave(iw).Roi.Last;
    Wave(iw).Roi.TimeArray = (Wave(iw).Roi.Array-1).*Factor;
    Wave(iw).RefCurve = RefCurve(Wave(iw).Roi.Array); %#ok<*AGROW>
    Wave(iw).IrfCurve = Irf(Wave(iw).Roi.Array);
    
    Wave(iw).Roi.InterpArray = Wave(iw).Roi.First:InterpStep:Wave(iw).Roi.Last;
    Wave(iw).Roi.TimeInterpArray = (Wave(iw).Roi.InterpArray-1).*Factor;
    Wave(iw).InterpRefCurve = interp1(Wave(iw).Roi.Array,Wave(iw).RefCurve,Wave(iw).Roi.InterpArray,'pchip')';
    Wave(iw).InterpIrfCurve = interp1(Wave(iw).Roi.Array,Wave(iw).IrfCurve,Wave(iw).Roi.InterpArray,'pchip')';
    
    [~,BarIrfPos,MaxIrfPos]=CalcWidth(Wave(iw).InterpIrfCurve,0.5);
    Wave(iw).InterpIrfPos = MaxIrfPos; LeftRange = 1:MaxIrfPos;RightRange=MaxIrfPos+1:numel(Wave(iw).InterpIrfCurve);
    Wave(iw).VisualInterpAlignedArray = [LeftRange RightRange]-MaxIrfPos;
    Wave(iw).VisualTimeInterpAlignedArray = Wave(iw).VisualInterpAlignedArray.*Factor*InterpStep;
    
    subplot1(iw);
    lines=semilogy(subH(iw),Wave(iw).VisualTimeInterpAlignedArray,[Wave(iw).InterpRefCurve./max(Wave(iw).InterpRefCurve) Wave(iw).InterpIrfCurve./max(Wave(iw).InterpIrfCurve)]);
    lines(1).Color = 'r';lines(2).Color = 'g';
    xlim([0 Wave(iw).VisualTimeInterpAlignedArray(end)]);xlabel ps
    title(num2str(Wavelengths(iw)));
    Wave(iw).Gate = CalcGate(Wave(iw).InterpRefCurve,numgate,Wave(iw));
end
delete(subH(iw+1:end))
FH.UserData.FigCategory = 'ReferenceGatesPlot';
FH.UserData.ReferenceGatesWaveS = Wave;
ParentFH.UserData.ReferenceGatesWaveS = Wave;
preunits = FH.Units; FH.Units = 'normalized';
CreatePushButton(FH,'units','normalized','String','Apply Gates','Position',[0 0 0.05 0.05],'CallBack',{@ApplyGates,ParentFH,MFH});
FH.Units = preunits;
AddToFigureListStruct(FH,MFH,'data',ParentFH.UserData.DatFilePath)

    function Gate=CalcGate(Curve,NumGate,Wave)
        Counts = sum(Curve(Wave.InterpIrfPos:end));
        CountsPerGate = Counts/NumGate;
        firstbin = Wave.InterpIrfPos;lastbin = Wave.InterpIrfPos;
        for ig = 1:NumGate
            partialcounts = 0; ib = lastbin; firstbin = lastbin;
            while partialcounts<=CountsPerGate && ib<=numel(Curve)
                partialcounts = sum(Curve(firstbin:ib));
                ib = ib + 1;
            end
            lastbin = ib-1;
            Gate(ig).Counts = sum(Curve(firstbin:ib-2));
            Gate(ig).Roi.First = firstbin;
            Gate(ig).Roi.Last = ib-2;
            Gate(ig).Roi.Array = Gate(ig).Roi.First:Gate(ig).Roi.Last;
            if ~(Gate(ig).Roi.First>=numel(Curve))
                vline(Wave.VisualTimeInterpAlignedArray(Gate(ig).Roi.First),'r:',num2str(ig),'percy',0.8+rem(ig,2)*0.1);
                vline(Wave.VisualTimeInterpAlignedArray(Gate(ig).Roi.Last));
            end
            Gate(ig).Roi.TimeArray = Wave.VisualTimeInterpAlignedArray(Gate(ig).Roi.Array);
            if firstbin>numel(Curve), firstbin = numel(Curve);end
            if lastbin>numel(Curve), lastbin = numel(Curve);end
        end
    end
end