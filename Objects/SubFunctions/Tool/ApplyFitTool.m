function message = ApplyFitTool(mtoolobj,completetoolname,toolname)
nobjs = numel(mtoolobj);
dosetstatus = false;
dosethistory = true;
if ~strcmpi(toolname{1},'dmua')
    Spe = GetExtCoeff(mtoolobj(1).Parent);
end
FigParents=unique(vertcat(mtoolobj.Parent));
nparents = numel(FigParents);
for ip = 1:nparents
    maxessetsobjs = FigParents(ip).Axes;
    max_sca = maxessetsobjs(contains({maxessetsobjs.Name},'\mu_{s}''','IgnoreCase',true));
    max_abs = maxessetsobjs(contains({maxessetsobjs.Name},'\mu_{a}','IgnoreCase',true));
    if isempty(max_abs)
        max_abs = maxessetsobjs(contains({maxessetsobjs.Name},'Dmua','IgnoreCase',true));
    end
    mua_lambda = arrayfun(@(ia)regexpi(max_abs(ia).Name,'(\d*)', 'match'),1:numel(max_abs));
    mua_lambda = str2double(mua_lambda);
    [~,indexes]=sort(mua_lambda);
    max_abs = max_abs(indexes);
    if ~isempty(max_sca)
        max_sca = max_sca(indexes);
    end
    switch toolname{1}
        case '2step'
            FigParents(ip).StartWait;
            [message,conc,sca] = Perform2StepFit(max_abs,max_sca,Spe,toolname{2});
            Plot2StepFit(FigParents(ip),conc,sca);
            FigParents(ip).StopWait;
        case 'dmua'
            FigParents(ip).StartWait;
            [message]=CreateDmuaMaps(FigParents(ip));
            FigParents(ip).StopWait;
    end
    for iobj = 1:nobjs
        maxesactvobj = mtoolobj(iobj).Axes;
        mtoolactvobj = mtoolobj(iobj);
        
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
end