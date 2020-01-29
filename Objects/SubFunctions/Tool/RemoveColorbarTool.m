function RemoveColorbarTool(mtoolobj,completetoolname,toolname)
dosetstatus = true;
dosethistory = true;
nobjs = numel(mtoolobj);
for iobj = 1:nobjs
    maxesactvobj = mtoolobj(iobj).Axes;
    mtoolactvobj = mtoolobj(iobj);
    switch toolname{1}
        case {'change','changelink'}
            RemoveColorbar(maxesactvobj);
    end
    history.data = maxesactvobj.ImageData;
    history.toolname = completetoolname;
    history.message = ['Removed ', toolname{1}, ' to colorbar'];
    if dosetstatus == true
        mtoolactvobj.Status.(completetoolname) = 0;
    end
    if dosethistory == true
        notify(maxesactvobj,'ToolApplied',historyeventdata(history));
    end
end

allmfigobjs=mtoolobj(1).Parent.GetAllFigs;
if any(logical([allmfigobjs.Selected]))
    mtoolobj(1).Parent.DeselectAll
end
end