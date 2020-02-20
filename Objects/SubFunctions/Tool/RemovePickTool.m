function RemovePickTool(mtoolobj,completetoolname,toolname)
nobjs = numel(mtoolobj);
dosetstatus = true;
dosethistory = true;
for iobj = 1:nobjs
    maxesactvobj = mtoolobj(iobj).Axes;
    mtoolactvobj = mtoolobj(iobj);
    dch=datacursormode(mtoolactvobj.Parent.Figure);
    dch.Enable = 'off';
    dch.UpdateFcn = [];
    dch.DisplayStyle = 'datatip';
    if strcmpi(toolname{1},'info')
       poiimh=mtoolobj.Parent.Menu(arrayfun(@(im) strcmpi(mtoolobj.GetToolName(mtoolobj.Parent.Menu(im)),'pickonimageinfo'),1:mtoolobj.Parent.nMenu));
       for imh=1:numel(poiimh.Children)
           poiimh.Children(imh).Checked = 'off';
       end
    end
    delete(findobj(maxesactvobj.axes,'type','constantline'));
    maxesactvobj.Parent.Figure.WindowState = 'maximized';
    if dosetstatus
        mtoolactvobj.Status.(completetoolname) = 0;
    end
    if dosethistory
        history.data = maxesactvobj.ImageData;
        history.toolname = completetoolname;
        history.message = ['Remove ' toolname{1} ' pick tool'];
        notify(maxesactvobj,'ToolApplied',historyeventdata(history));
    end
end


end