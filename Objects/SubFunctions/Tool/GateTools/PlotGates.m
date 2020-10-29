function PlotGates(Wave,FileName,mtoolobj)
mfigobj=mfigure('Name',['Gates - ',FileName],'WindowState','maximized','Category','Gates');
mfigobj.StartWait;
if isfield(mfigobj.Graphicals,'NaviGates')
    delete(mfigobj.Graphicals.NaviGates);
end
Wavelengths = mfigobj.Wavelengths;
nSub = numSubplots(numel(Wavelengths));
tiledlayout(nSub(1),nSub(2),'Padding','none','TileSpacing','none');
for iw = 1:numel(Wavelengths)
    ah=nexttile;
    PlotGatePage(Wave,ah,iw,Wave(iw).DefaultGate,mtoolobj);
end
mfigobj.Data.Wave = Wave;
mfigobj.StopWait;
mfigobj.AddAxesToFigure;
% for iw = 1:numel(Wavelengths)
%     lambda = regexpi(mfigobj.Axes(iw).Name,'(\d)+.\s','tokens');
%     lambda = str2double(cell2mat(lambda{1}))==Wavelengths;
%     if any(lambda)
%         mfigobj.Axes(iw).CLim = Wave(lambda).Limits;
%     end
% end
end