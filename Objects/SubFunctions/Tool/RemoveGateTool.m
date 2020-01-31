function RemoveGateTool(mtoolobj,completetoolname,toolname,varargin)
nobjs = numel(mtoolobj);
dosetstatus = true;
dosethistory = true;
for iobj = 1:nobjs
    maxesactvobj = mtoolobj(iobj).Axes;
    mtoolactvobj = mtoolobj(iobj);
    switch toolname{1}
        case 'reference'
            if strcmpi(toolname{2},'point')
                dch=datacursormode(mtoolactvobj.Parent.Figure);
                dch.Enable = 'off';
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