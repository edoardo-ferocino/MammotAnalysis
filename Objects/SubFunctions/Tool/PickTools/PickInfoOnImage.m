function message = PickInfoOnImage(mtoolobj,toolname)
switch toolname{1}
    case 'activated'
        if isfield(mtoolobj.Parent.Data,'Fit')
            poiimh=mtoolobj.Parent.Menu(arrayfun(@(im) strcmpi(mtoolobj.GetToolName(mtoolobj.Parent.Menu(im)),'pickonimageinfo'),1:mtoolobj.Parent.nMenu));
            if numel(poiimh.Children)==1
                arrayfun(@(ifilters) uimenu(poiimh,'Text',mtoolobj.Parent.Data.Fit.Filters(ifilters).Name,'Tag',[poiimh.Tag mtoolobj.Parent.spacer mtoolobj.Parent.Data.Fit.Filters(ifilters).Name],'MenuSelectedFcn',@SetCheckedStatus),1:numel(mtoolobj.Parent.Data.Fit.Filters));
            end
        end
        message = 'Pick Info activated';
        dch = datacursormode(mtoolobj.Parent.Figure);
        datacursormode on
        dch.DisplayStyle = 'window';
        dch.UpdateFcn = {@PickInfo,mtoolobj.Parent,poiimh};
end
end
function output_txt=PickInfo(datacursorobj,~,mfigobj,poiimh)
persistent PreviousParent
persistent Times
AxesNames = {mfigobj.Axes.Name};
maxesobj = mfigobj.Axes(strcmpi(AxesNames,datacursorobj.Parent.Title.String));
if isempty(PreviousParent)||isequal(PreviousParent,maxesobj)
    PreviousParent = maxesobj;
    Times = 1;
else
    if ~isequal(PreviousParent,maxesobj)
        if Times == 1
            Times = Times + 1;
            output_txt = {'Wait'};
            return;
        else
            Times = 1;
            PreviousParent = maxesobj;
        end
    end
end
pos = datacursorobj.Position; cpos = pos(1); rpos = pos(2);
checkedonmenus=arrayfun(@(im) strcmpi(poiimh.Children(im).Checked,'on')&&~strcmpi(poiimh.Children(im).Text,'&activated'),1:numel(poiimh.Children));
checkedmenusname={poiimh.Children(checkedonmenus).Text};
logicalindexes = cellfun(@(im) strcmpi(mfigobj.Data.Fit.Data.Properties.VariableNames,im)',checkedmenusname,'UniformOutput',false);
if isempty(logicalindexes),output_txt = 'Select an info'; return; end
XY = cellfun(@(im) strcmpi(mfigobj.Data.Fit.Data.Properties.VariableNames,im)',{'X' 'Y'},'UniformOutput',false);
logicalindexes=cell2mat(logicalindexes);XY=cell2mat(XY);
logicalindexes=any(logicalindexes,2)';XY=any(XY,2)';
if numel(mfigobj.Data.Fit.ActualRows)>1 && strcmpi(mfigobj.Data.Fit.Type,'OptProps')
   CatNames=string(mfigobj.Data.Fit.Filters(vertcat(mfigobj.Data.Fit.Filters.LambdaFilter)).SelectedCategory);
   PageID=find(arrayfun(@(icn) contains(maxesobj.Name,CatNames(icn)),1:numel(CatNames)));
else
   PageID = 1; 
end
AllData=mfigobj.Data.Fit.Data(mfigobj.Data.Fit.ActualRows{PageID},or(logicalindexes,XY));
InfoData=mfigobj.Data.Fit.Data(mfigobj.Data.Fit.ActualRows{PageID},logicalindexes);
InfoData=InfoData(and(AllData.X == cpos-1,AllData.Y == rpos-1),:);
string2plot = cell.empty(size(InfoData,2),0);
for ic = 1:size(InfoData,2)
    if strcmpi(InfoData.Properties.VariableUnits{ic},'double')
        newval = num2str(mean(InfoData(:,ic).Variables));
    elseif strcmpi(InfoData.Properties.VariableUnits{ic},'char')
        newval = unique(InfoData(:,ic).Variables);
        newval=strjoin(newval,',');
    end
    string2plot{ic} = [InfoData.Properties.VariableNames{ic}, ': ',newval];
end
Data = maxesobj.ImageData;
output_txt = [...
    {maxesobj.Name},...
    {strcat('X: ',num2str(round(cpos)))},...
    {strcat('Y: ',num2str(round(rpos)))},...
    {strcat('Z: ',num2str(Data(rpos,cpos)))},...
    string2plot];
maxesobj.Parent.Show;
end
function SetCheckedStatus(menuobj,~)
if strcmpi(menuobj.Checked,'on')
    menuobj.Checked = 'off';
else
    menuobj.Checked = 'on';
end
end