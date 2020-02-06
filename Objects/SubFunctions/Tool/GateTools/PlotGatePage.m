function PlotGatePage(Wave,SubH,iw,ig,mtoolobj)
Imh=findobj(SubH,'type','image');
if isempty(Imh)
    imagesc(Wave(iw).Gate(ig).Data);
else
    mtoolobj.Axes.ImageData = Wave(iw).Gate(ig).Data;
end
%          title({num2str(Wave(iw).Name) ...
%              [...
% %              num2str(Wave(iw).Gate(ig).TimeArray(1),'%.0f') '-' ...
% %              num2str(Data(iw).Gate(ig).TimeArray(end),'%.0f') ' ps.' ...
%              num2str(ig) '/' num2str(Wave(iw).NumGate)]});
title(SubH,[num2str(Wave(iw).Name) '. Gate ' num2str(ig) '/' num2str(Wave(iw).NumGate)]);
end
