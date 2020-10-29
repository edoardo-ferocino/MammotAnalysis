function ApplyColorbarTool(mtoolobj,completetoolname,toolname)
nobjs = numel(mtoolobj);
dosetstatus = true;
dosethistory = true;
DuplicateAxesName = [];
maxessetsobjs = [];
selectedfigures=numel(unique(vertcat(mtoolobj.Parent)))>1;
if selectedfigures
    allaxesobjs=vertcat(mtoolobj.Axes);
    AxesName={allaxesobjs.Name};
    [~,indexes]=unique(AxesName,'stable');
    duplicate_indices = setdiff( 1:numel(AxesName), indexes );
    DuplicateAxesName = AxesName(duplicate_indices);
    indexesvect = arrayfun(@(di)strcmpi(AxesName,AxesName(di)),duplicate_indices,'UniformOutput',false)';
    maxessetsobjs = arrayfun(@(di)vertcat(allaxesobjs(indexesvect{di})),1:numel(indexesvect),'UniformOutput',false)';
end

for iobj = 1:nobjs
    maxesactvobj = mtoolobj(iobj).Axes;
    mtoolactvobj = mtoolobj(iobj);
    switch toolname{1}
        case 'change'
            ChangeColorbarTool(maxesactvobj,toolname(2:end),maxessetsobjs,DuplicateAxesName,mtoolobj);
        case 'restore'
            RestoreColorbar(maxesactvobj);
            dosetstatus = false;
    end
    if dosetstatus
        mtoolactvobj.Status.(completetoolname) = 1;
    end
    if dosethistory
        history.roi = mtoolactvobj.Roi;
        history.data = maxesactvobj.ImageData;
        history.toolname = completetoolname;
        history.message = ['Applied ', toolname{1}, ' to colorbar'];
        notify(maxesactvobj,'ToolApplied',historyeventdata(history));
    end
end
if selectedfigures
    mtoolobj(1).Parent.DeselectAll;
end
end