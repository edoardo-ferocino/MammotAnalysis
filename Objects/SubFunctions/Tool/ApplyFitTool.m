function message = ApplyFitTool(mtoolobj,completetoolname,toolname)
nobjs = numel(mtoolobj);
dosetstatus = false;
dosethistory = true;
Spe = GetExtCoeff(mtoolobj(1).Parent);
FigParents=unique(vertcat(mtoolobj.Parent));
nparents = numel(FigParents);
for ip = 1:nparents
    maxessetsobjs = FigParents(ip).Axes;
    max_sca = maxessetsobjs(contains({maxessetsobjs.Name},'\mu_{s}''','IgnoreCase',true));
    max_abs = maxessetsobjs(contains({maxessetsobjs.Name},'\mu_{a}','IgnoreCase',true));
    mua_lambda = arrayfun(@(ia)regexpi(max_abs(ia).Name,'\\mu_{a}, \\lambda = (\d*)', 'tokens'),1:numel(max_abs));
    mua_lambda = arrayfun(@(ia)mua_lambda{ia},1:numel(max_abs));
    mua_lambda = str2double(mua_lambda);
    [~,indexes]=sort(mua_lambda);
    max_sca = max_sca(indexes);
    max_abs = max_abs(indexes);
    switch toolname{1}
        case '2step'
            [message,conc,sca] = Perform2StepFit(max_abs,max_sca,Spe,toolname{2});
            Plot2StepFit(FigParents(ip),conc,sca);
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


