function RemoveRoiTool(mtoolobj,completetoolname,toolname,varargin)
nobjs = numel(mtoolobj);
dosetstatus = true;
dosethistory = true;
for iobj = 1:nobjs
    maxesactvobj = mtoolobj(iobj).Axes;
    mtoolactvobj = mtoolobj(iobj);
    switch toolname{1}
        case 'movetogether'
            message = RemoveMoveTogether(mtoolactvobj);
        case 'name'
            message = RemoveNameRoi(mtoolactvobj);
            if ~contains(lower(message),'error')
                dosetstatus = true;
            else
                dosetstatus = false;
            end
    end
    if dosetstatus
        mtoolactvobj.Status.(completetoolname) = 0;
    end
    if dosethistory
        history.data = maxesactvobj.ImageData;
        history.toolname = completetoolname;
        history.message = message;
        notify(maxesactvobj,'ToolApplied',historyeventdata(history));
    end
end


end