function message = ApplyGateTool(mtoolobj,completetoolname,toolname)
nobjs = numel(mtoolobj);
dosetstatus = false;
dosethistory = true;
for iobj = 1:nobjs
    maxesactvobj = mtoolobj(iobj).Axes;
    mtoolactvobj = mtoolobj(iobj);
    switch toolname{1}
        case 'reference'
            message = SelectReference(mtoolactvobj,toolname(2:end),nobjs,iobj);
            if strcmpi(toolname{2},'point')
                dosetstatus = true;
            end
        case 'apply'
            message = ApplyReference(mtoolactvobj);
        case 'navigate'
            message = NavigateGates(mtoolactvobj);
            dosetstatus = true;
    end
    if dosetstatus==true
        mtoolactvobj.Status.(completetoolname) = 1;
    end
    if dosethistory==true
        history.roi = mtoolactvobj.Roi;
        history.data = maxesactvobj.ImageData;
        history.toolname = completetoolname;
        history.message = message;
        notify(maxesactvobj,'ToolApplied',historyeventdata(history));
    end
end

end