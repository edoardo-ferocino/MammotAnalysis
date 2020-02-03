function ApplyCompareTool(mtoolobj,completetoolname,toolname)
persistent ID
dosetstatus = false;
dosethistory = true;
if isempty(ID),ID=0;toolname{1}='new';end
switch toolname{1}
    case 'new'
        ID=ID+1;
    case 'existent'
        mselectfigobj = mtoolobj(1).Parent.SelectMultipleFigures([],[],'select');%here, it selects only one compare figure
        waitfor(mselectfigobj.Figure,'Visible','off');
        allmfigobjs = mselectfigobj.GetAllFigs;
        ID = regexpi(allmfigobjs(vertcat(allmfigobjs.Selected)).Tag,'(\d+)','match');
        ID = str2double(ID{1});
        allmfigobjs(vertcat(allmfigobjs.Selected)).Selected = false;
end
mfigobj=mfigure('Name',['Compare figures ' num2str(ID)],'Tag',['comparefigure',num2str(ID)],'Category','Compare');
tlh=findobj(mfigobj.Figure,'Type','tiledlayout');
if isempty(tlh)
    tlh=tiledlayout(mfigobj.Figure,'flow','Padding','none','TileSpacing','none');
end
nobjs = numel(mtoolobj);
if mfigobj.nTool~=0
    delete(vertcat(mfigobj.Axes.Colorbar));
end
for iobj = 1:nobjs
    nexttile(tlh);
    maxesactvobj = mtoolobj(iobj).Axes;
    mtoolactvobj=mtoolobj(iobj);
    %
    imagesc(maxesactvobj.ImageData);
    title(maxesactvobj.Name);
    %
    if dosetstatus == true
        mtoolactvobj.Status.(completetoolname) = 1;
    end
    if dosethistory == true
        history.roi = mtoolactvobj.Roi;
        history.data = maxesactvobj.ImageData;
        history.toolname = completetoolname;
        history.message = 'Sent to compare';
        notify(maxesactvobj,'ToolApplied',historyeventdata(history));
    end
end
mfigobj.AddAxesToFigure;
mfigobj.DeselectAll;
end