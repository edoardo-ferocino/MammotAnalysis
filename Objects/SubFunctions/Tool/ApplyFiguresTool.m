function ApplyFiguresTool(mtoolobj,completetoolname,toolname)
mfigobjs = unique(vertcat(mtoolobj.Parent));
mfigobjs(1).DeselectAll;
nobjs = numel(mfigobjs);
dosetstatus = false;
dosethistory = true;
for iobj = 1:nobjs
    maxesactvobj = mtoolobj(iobj).Axes;
    mtoolactvobj = mtoolobj(iobj);
    switch toolname{1}
        case 'save'
            mfigobjs(iobj).Save;
        case 'load'
            mfigobjs(iobj).Load;
            nobjs = 1;
    end
    if dosetstatus==true
        mtoolactvobj.Status.(completetoolname) = 1;
    end
    if dosethistory==true
        history.roi = mtoolactvobj.Roi;
        history.data = maxesactvobj.ImageData;
        history.toolname = completetoolname;
        history.message = 'Figure saved';
        notify(maxesactvobj,'ToolApplied',historyeventdata(history));
    end
end

end