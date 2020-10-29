function RemoveColorbar(maxesobj)
delete(maxesobj.Graphical.dch);
delete(maxesobj.Graphical.uch);
maxesobj.Graphical = rmfield(maxesobj.Graphical,'dch');
maxesobj.Graphical = rmfield(maxesobj.Graphical,'uch');
end
