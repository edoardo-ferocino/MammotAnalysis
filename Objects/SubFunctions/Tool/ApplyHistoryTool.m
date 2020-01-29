function ApplyHistoryTool(mtoolobj,completetoolname,toolname)
nobjs = numel(mtoolobj);
for iobj = 1:nobjs
    dosetstatus = false;
    dosethistory = true;
    maxesactvobj = mtoolobj(iobj).Axes;
    mtoolactvobj = mtoolobj(iobj);
    switch toolname{1}
        case 'back'
            if maxesactvobj.HistoryIndex-1 >= 1
                maxesactvobj.ImageData = maxesactvobj.History(maxesactvobj.HistoryIndex-1).Data;
                message = 'Back';
            else
                dosethistory = false;
            end
            dosetstatus = false;
        case 'forth'
            if maxesactvobj.HistoryIndex+1 <= numel(maxesactvobj.History)
                maxesactvobj.ImageData = maxesactvobj.History(maxesactvobj.HistoryIndex+1).Data;
                message = 'Forth';
            else
                dosethistory = false;
            end
            dosetstatus = false;
    end
    maxesactvobj.CLim = GetPercentile(maxesactvobj.ImageData,[maxesactvobj.LowPercentile maxesactvobj.HighPercentile]);
    if dosetstatus
        mtoolactvobj.Status.(completetoolname) = 1;
    end
    if dosethistory
        history.roi = mtoolactvobj.Roi;
        history.data = maxesactvobj.ImageData;
        history.toolname = completetoolname;
        history.message = message;
        notify(maxesactvobj,'ToolApplied',historyeventdata(history));
    end
end
end
