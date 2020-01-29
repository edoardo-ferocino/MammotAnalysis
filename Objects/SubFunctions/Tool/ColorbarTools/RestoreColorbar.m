function RestoreColorbar(maxesobj)
dch=findobj('Tag',strcat(maxesobj.Parent.Tag,maxesobj.Name,'down'));
uch=findobj('Tag',strcat(maxesobj.Parent.Tag,maxesobj.Name,'up'));
maxesobj.CLim = maxesobj.OriginalCLim;
if isempty(dch), return, end
dch.String = num2str(maxesobj.CLim(1));
uch.String = num2str(maxesobj.CLim(2));
end