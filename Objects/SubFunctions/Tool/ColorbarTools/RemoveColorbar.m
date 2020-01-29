function RemoveColorbar(maxesobj)
dch=findobj('Tag',[maxesobj.Parent.Tag maxesobj.Name 'down']);
uch=findobj('Tag',[maxesobj.Parent.Tag maxesobj.Name 'up']);
delete([dch uch]);
end
