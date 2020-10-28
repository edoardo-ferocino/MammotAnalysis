function DeselectAll(mfigobj,~,~)
mfigobj.StartWait;
allmfigobjs = mfigobj.GetAllFigs('all');
arrayfun(@(ifs)SetFigToogle(allmfigobjs(ifs),false),1:numel(allmfigobjs));
mfigobj.UpdateMultiSelect;
mfigobj.StopWait;
end
function SetFigToogle(mfigobj,value)
mfigobj.StrictSelected = value;
end