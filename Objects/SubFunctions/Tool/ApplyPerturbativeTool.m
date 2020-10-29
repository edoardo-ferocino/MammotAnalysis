function message = ApplyPerturbativeTool(mtoolobj,completetoolname,toolname)
nobjs = numel(mtoolobj);
dosetstatus = false;
dosethistory = true;
for iobj = 1:nobjs
    maxesactvobj = mtoolobj(iobj).Axes;
    mtoolactvobj = mtoolobj(iobj);
    switch toolname{1}
        case 'identifylesion'
            message = IdentifyLesion(mtoolactvobj,toolname{2});
        case 'dat'
            message = GenerateDat(mtoolactvobj);
        case 'irf'
            message = GenerateIrf(mtoolactvobj);
        case 'multicurve'
            message = GenerateMulticurve(mtoolactvobj);
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