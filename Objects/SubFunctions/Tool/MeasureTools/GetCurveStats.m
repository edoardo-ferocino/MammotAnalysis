function Stats = GetCurveStats(maxesobj,CalcWidthLevel)
Data = maxesobj.axes.Children.YData;
if numel(Data) == maxesobj.Parent.Data.DatInfo.CH.McaChannNum
    Rois = maxesobj.Parent.Data.TrsSet.Roi(:,[2 3])+1;
    Shift = Rois(:,1);
else
    Rois = [1 numel(Data)];
    Shift = maxesobj.axes.Children.XData(1);
end
for ir = 1:size(Rois,1)
    Stat.FileName = maxesobj.Parent.Data.FileName;
    Stat.AxesName = maxesobj.Name;
    Stat.Counts = sum(Data(Rois(ir,1):Rois(ir,2)));
    [Stat.Width,Stat.BarPos,Stat.MaxPos,Stat.MaxVal] = CalcWidth(Data(Rois(ir,1):Rois(ir,2)),CalcWidthLevel);
    Stat.BarPos = round(Stat.BarPos + Shift(ir) - 1);
    Stat.MaxPos = round(Stat.MaxPos + Shift(ir) - 1);
    Stat.Width = num2str(round(Stat.Width*maxesobj.Parent.Data.DatInfo.CH.McaFactor,2),'%0.2f');
    Stat.Roi = num2str(Rois(ir,:));
    Stats(ir) = Stat;
end
end