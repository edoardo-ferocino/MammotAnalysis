function message = ApplyRoiTool(mtoolobj,completetoolname,toolname,shape2copy)
if ~exist('shape2copy','var')
    shape2copy = [];
end
newcolor = [];
nobjs = numel(mtoolobj);
dosetstatus = false;
dosethistory = true;
type = 'roi';
if contains(completetoolname,'border')
    type = 'border';
elseif contains(completetoolname,'gate')
    type = 'gate';
end
for iobj = 1:nobjs
    maxesactvobj = mtoolobj(iobj).Axes;
    mtoolactvobj = mtoolobj(iobj);
    switch toolname{1}
        case 'shape'
            message = ApplyShape(mtoolactvobj,toolname{2},type,shape2copy);
            if nobjs>1 && iobj == 1
                shape2copy = mtoolactvobj.Roi(end).Shape;
            end
        case 'copy'
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
        case 'changecolor'
            [message,newcolor] = ChangeRoiColor(mtoolactvobj,newcolor);
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
            message = DeleteBorder(mtoolactvobj,toolname{2});
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