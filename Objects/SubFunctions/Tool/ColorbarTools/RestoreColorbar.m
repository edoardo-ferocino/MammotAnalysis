function RestoreColorbar(maxesobj)
dch = maxesobj.Graphical.dch;
uch = maxesobj.Graphical.uch;
maxesobj.CLim = maxesobj.OriginalCLim;
if isempty(dch), return, end
dch.String = num2str(maxesobj.CLim(1));
uch.String = num2str(maxesobj.CLim(2));
end