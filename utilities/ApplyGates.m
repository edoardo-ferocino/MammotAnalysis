function Wave = ApplyGates(src,~,ParentFH,MFH)
AncestorFigure = ancestor(src,'figure');
StartWait(AncestorFigure);
Bkg = mean(ParentFH.UserData.VisualDatData(:,:,:,str2double(MFH.UserData.BkgFirst.String):str2double(MFH.UserData.BkgLast.String)),4);
AllData = ParentFH.UserData.VisualDatData - Bkg;
AllData = squeeze(AllData);
ReferenceGatesWaveS = ParentFH.UserData.ReferenceGatesWaveS;
numwave = numel(MFH.UserData.Wavelengths);
Roi = ParentFH.UserData.TrsSet.Roi(1:numwave,2:3)+1;
numgate = str2double(MFH.UserData.NumGate.String);

for iw=1:numwave
    Wave(iw).ReferenceGatesWaveS = ReferenceGatesWaveS(iw);
    Wave(iw).Data = AllData(:,:,Roi(iw,1):Roi(iw,2)); %#ok<*AGROW>
    Wave(iw).InterpData = permute(Wave(iw).Data,[3 1 2]);
    OrigSize = size(Wave(iw).InterpData);
    Wave(iw).InterpData = reshape(Wave(iw).InterpData,[OrigSize(1) prod(OrigSize(2:3))]);
    Wave(iw).InterpData = interp1(ReferenceGatesWaveS(iw).Roi.Array,Wave(iw).InterpData,ReferenceGatesWaveS(iw).Roi.InterpArray,'pchip');
    Wave(iw).InterpData = reshape(Wave(iw).InterpData,[numel(ReferenceGatesWaveS(iw).Roi.InterpArray) OrigSize(2:3)]);
    Wave(iw).InterpData = permute(Wave(iw).InterpData,[2 3 1]);
    for ig = 1:numgate
        Wave(iw).Gates(ig).Array = ReferenceGatesWaveS(iw).Gate(ig).Roi.Array;
        Wave(iw).Gates(ig).TimeArray = ReferenceGatesWaveS(iw).Gate(ig).Roi.TimeArray;
        Wave(iw).Gates(ig).Curves = zeros(size(Wave(iw).InterpData));
        Wave(iw).Gates(ig).Curves(:,:,ReferenceGatesWaveS(iw).Gate(ig).Roi.Array)=Wave(iw).InterpData(:,:,ReferenceGatesWaveS(iw).Gate(ig).Roi.Array);
        Wave(iw).Gates(ig).Counts = squeeze(sum(Wave(iw).Gates(ig).Curves,3));
    end
end
ParentFH.UserData.GatesWaveS = Wave;
PlotGates(ParentFH,MFH);
StopWait(AncestorFigure);
end