function RemoveMeasureTool(mtoolobj,completetoolname,toolname)
dosetstatus = true;
dosethistory = true;
nobjs = numel(mtoolobj);
for iobj = 1:nobjs
    maxesactvobj = mtoolobj(iobj).Axes;
    mtoolactvobj = mtoolobj(iobj);
    switch toolname{1}
        case {'perimeter','area'}
            selectedshapes = vertcat(mtoolactvobj.Roi(vertcat(mtoolactvobj.Roi.Selected)).Shape);
            for is = 1:numel(selectedshapes)
               selectedshapes(is).Label = char.empty; 
            end
    end
    if dosetstatus == true
        mtoolactvobj.Status.(completetoolname) = 0;
    end
    if dosethistory == true
        history.data = maxesactvobj.ImageData;
        history.toolname = completetoolname;
        history.message = ['Removed ', toolname{1}, ' to colorbar'];
        notify(maxesactvobj,'ToolApplied',historyeventdata(history));
    end
end

end