function ApplyPickTool(mtoolobj,completetoolname,toolname)
nobjs = numel(mtoolobj);
dosetstatus = true;
dosethistory = true;
for iobj = 1:nobjs
    maxesactvobj = mtoolobj(iobj).Axes;
    mtoolactvobj = mtoolobj(iobj);
    switch toolname{1}
        case 'curve'
            message = PickCurveOnImage(mtoolactvobj);
        case 'spectra'
            message = PickSpectraOnImage(mtoolactvobj);
        case 'info'
            message = PickInfoOnImage(mtoolactvobj,toolname(2:end));
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
