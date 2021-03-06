function RemoveProfileTool(mtoolobj,completetoolname,toolname)
nobjs = numel(mtoolobj);
dosetstatus = true;
dosethistory = true;
for iobj = 1:nobjs
    maxesactvobj = mtoolobj(iobj).Axes;
    mtoolactvobj = mtoolobj(iobj);
    dch=datacursormode(mtoolactvobj.Parent.Figure);
    dch.Enable = 'off';
    delete(findobj(maxesactvobj.axes,'type','constantline'));
    maxesactvobj.Parent.Figure.WindowState = 'maximized';
    if dosetstatus
        mtoolactvobj.Status.(completetoolname) = 0;
    end
    if dosethistory
        history.data = maxesactvobj.ImageData;
        history.toolname = completetoolname;
        history.message = ['Remove ' toolname{1} ' profile tool'];
        notify(maxesactvobj,'ToolApplied',historyeventdata(history));
    end
end


end