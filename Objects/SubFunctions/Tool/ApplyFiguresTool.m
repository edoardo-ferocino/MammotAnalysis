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
            [FileName,FilePath,FilterIndex]=uiputfilecustom('*.fig',mfigobjs(iobj).Name);
            if FilterIndex == 0, return; end
            savefig(mfigobjs(iobj).Figure,fullfile(FilePath,FileName))
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