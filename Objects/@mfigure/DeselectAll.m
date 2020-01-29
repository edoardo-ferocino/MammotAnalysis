function DeselectAll(mfigobj,~,~)
allmfigobjs = mfigobj.GetAllFigs('all');
arrayfun(@(ifs)SetFigToogle(allmfigobjs(ifs),false),1:numel(allmfigobjs));
end
function SetFigToogle(mfigobj,value)
mfigobj.Selected = value;
end