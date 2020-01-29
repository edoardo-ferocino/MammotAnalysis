function ApplyOverlapTool(mtoolobj,completetoolname,toolname)
nobjs = numel(mtoolobj);
dosetstatus = false;
dosethistory = true;
Overlap = [];
for iobj = 1:nobjs
    maxesactvobj = mtoolobj(iobj).Axes;
    mtoolactvobj = mtoolobj(iobj);
    %     switch toolname{1}
    %         case 'Drawing'
    Overlap=OverlapDrawing(mtoolactvobj,Overlap);
    %     end
    if dosetstatus == true
        mtoolactvobj.Status.(completetoolname) = 1;
    end
    if dosethistory == true
        history.roi = mtoolactvobj.Roi;
        history.data = maxesactvobj.ImageData;
        history.toolname = completetoolname;
        history.message = 'Applied overlap';
        notify(maxesactvobj,'ToolApplied',historyeventdata(history));
    end
end

end