function SaveFig(fh)
PathName = uigetdircustom('Select destination');
if PathName == 0, return, end
FullPath = fullfile(PathName,fh.Name);
warning off
figh = copyfig(fh);
allchildren = findobj(figh,'Parent',figh);
shapes = findobj(figh,'type','shape');
if ~isempty(shapes)
   answer=questdlg('Preserve annotations?','What should I do?','Yes','No','No'); 
   if strcmpi(answer,'no')
       shapes = [];
   end
end
axh = [findobj(figh,'type','axes') shapes];
delete(setdiff(allchildren, axh));
figure(figh);
for iaxh = 1:numel(axh)
    axh(iaxh).Title = [];
    axh(iaxh).UserData = [];
    axh(iaxh).Children.UserData = [];
end
reset(figh)
colormap pink
save_figure(FullPath,figh,'-png','-pdf','-svg');
delete(figh);
warning on
msgbox('Figure saved','Success','Help');
end