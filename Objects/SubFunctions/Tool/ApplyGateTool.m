function message = ApplyGateTool(mtoolobj,completetoolname,toolname)
nobjs = numel(mtoolobj);
dosetstatus = false;
dosethistory = true;
allparents = unique(mtoolobj.Parent);
if numel(allparents)>1
    DisplayError('The selected axes does not apply','Select an axes of a "Total" image');
    return;
elseif ~strcmpi(allparents.Category,'Counts')
    DisplayError('The selected axes does not apply','Select an axes of a "Total" image');
    return;
end
for iobj = 1:nobjs
    maxesactvobj = mtoolobj(iobj).Axes;
    mtoolactvobj = mtoolobj(iobj);
    switch toolname{1}
        case 'reference'
            message = SelectAndApplyRefence(mtoolactvobj,toolname(2:end),nobjs,iobj);
       case 'apply'
            message = CopyRoi(mtoolactvobj);
        case 'paste'
            [message,allcopiedroiobjs] = PasteRoi(mtoolactvobj);
            if iobj==nobjs
                for ic = 1:numel(allcopiedroiobjs)
                    allcopiedroiobjs(ic).CopiedRoi = false;
                end
                mtoolactvobj.Parent.DeselectAll;
            end
        case 'name'
            message = NameRoi(mtoolactvobj,toolname(2:end));
            if ~contains(lower(message),'error')
                dosetstatus = true;
            else
                dosetstatus = false;
            end
        case 'movetogether'
            message = MoveTogether(mtoolactvobj,mtoolobj);
            dosetstatus = true;
        case 'show'
            if iobj == 1
                message = ShowRois(mtoolobj);
                dosetstatus = false;
                dosethistory = false;
            end
        case 'delete'
            message = DeleteRoi(mtoolactvobj);
        case 'deleteborder'
            message = DeleteTool(mtoolactvobj,toolname{2});
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