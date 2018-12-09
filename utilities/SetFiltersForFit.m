function SetFiltersForFit(AllData,FitParams,Filters,MFH)
[~,name,~] = fileparts(MFH.UserData.DispFitFilePath.String);
global FigureName;
FigureName = ['Plot fitted values - ' name];
global PercFract
PercFract = 95;
FigFilterName = ['Select filters - ' name];
global FigFilterHandle
FigFilterHandle = findobj('Type','figure','-and','Name',FigFilterName);
if ~isempty(FigFilterHandle)
    figure(FigFilterHandle);
else
    FigFilterHandle=figure('Name',FigFilterName,'Toolbar','None','MenuBar','none');
end
AddToFigureListStruct(FigFilterHandle,MFH,'side');

if strcmpi(Filters(1).FitType,'muamus')
    addcheckbox = true;
else
    addcheckbox = false;
end
for ifil = 1:numel(Filters)
    ch = CreateContainer(FigFilterHandle,'Units','pixels','Position',[0 FigFilterHandle.Position(4)/numel(Filters)*(ifil-1) FigFilterHandle.Position(3) FigFilterHandle.Position(4)/numel(Filters)],'BorderType','none');
    poph(ifil) = CreatePopUpMenu(ch,'Units','Normalized','String',Filters(ifil).Categories,...
        'Position',[0 0 0.3 0.8],'Value',1);
    poph(ifil).UserData.IDFilter = ifil; %#ok<*AGROW>
    CreateEdit(ch,'Units','Normalized','Position',...
        [0.4 0.3 0.3 0.5],'String',Filters(ifil).Name,'HorizontalAlignment','left');
    if addcheckbox
        cbh(ifil) = CreateCheckBox(ch,'Units','Normalized','Position',...
            [0.75 0.3 0.3 0.5],'String','Is lambda filter','Callback',{@Checked});
    else
        cbh(ifil) = 0;
    end
end
movegui(FigFilterHandle,'northeast')


for ifil = 1:numel(Filters)
    poph(ifil).Callback = {@SetFilter,poph,cbh};
end
    function Checked(src,~)
        src.UserData.Value = src.Value;
    end
    function SetFilter(~,~,poph,cbh)
        StartWait(FigFilterHandle);
        for ip = 1:numel(poph)
            Filters(ip).ActualValue = poph(ip).String{poph(ip).Value};
            Filters(ip).Checked = 0;
            if ~strcmpi(Filters(ip).ActualValue,'Any')
                if strcmpi(Filters(ip).Type,'double')
                    Filters(ip).ActualValue = str2double(Filters(ip).ActualValue);
                end
                if strcmpi(Filters(ip).Type,'char')
                    Filters(ip).ActualValue = Filters(ip).ActualValue;
                end
            end
            if ~isnumeric(cbh(ip))
                if cbh(ip).Value
                    if strcmpi(Filters(ip).Type,'double')
                        Filters(ip).ActualValue = str2double(poph(ip).String(2:end));
                    end
                    Filters(ip).Checked = 1;
                end
            end
            FigFilterHandle.UserData.Filters(ip) = Filters(ip);
        end
        MFH.UserData.Filters = Filters;
        MFH.UserData.FitParams = FitParams;
        [Pages,rows] = CreateActualPage();
        if isempty(Pages)
            StopWait(FigFilterHandle);
            return
        end
        MFH.UserData.rows = rows;
        MFH.UserData.AllData = AllData;
        PlotPages(Pages,rows);
        StopWait(FigFilterHandle);
    end
    function [ActualPage,ActualRows] = CreateActualPage()
        cols = sort([FitParams.ColID]);
        actpage = 1; nactv = 1;
        if find([Filters.Checked])
            nactv = numel(Filters(find([Filters.Checked])).ActualValue); %#ok<FNDSB>
        end
        for av = 1:nactv
            ip = 1; rows = zeros(size(AllData(:,1).Variables,1),1);
            for ifilt = 1:numel(Filters)
                if ~strcmpi(Filters(ifilt).ActualValue,'Any')
                    if Filters(ifilt).Checked
                        rows(:,ip)= AllData.(Filters(ifilt).Name) == Filters(ifilt).ActualValue(av);
                    else
                        if strcmpi(Filters(ifilt).Type,'char')
                            rows(:,ip) = strcmpi(AllData.(Filters(ifilt).Name),Filters(ifilt).ActualValue);
                        else
                            rows(:,ip)= AllData.(Filters(ifilt).Name) == Filters(ifilt).ActualValue;
                        end
                    end
                    ip = ip +1;
                else
                    rows(:,ip) = ones(numel(AllData(:,1)),1);
                    ip = ip +1;
                end
            end
            rows = all(rows,2);
            if sum(rows)==numel(rows)
                ActualPage = [];ActualRows = [];
                msh = msgbox({'This combination of filters won''t work.' 'Please select a valid filter combination'},'Warning','help');
                movegui(msh,'center');
                return
            end
            Page = AllData(rows,cols);
            ActualPage{actpage}= Page;
            ActualRows(:,actpage) = rows;
            actpage = actpage+1;
        end
    end
    function PlotPages(Pages,rows)
        XColID = find(strcmpi(Pages{1}.Properties.VariableNames,'X'));
        YColID = find(strcmpi(Pages{1}.Properties.VariableNames,'Y'));
        [nsub]=numSubplots(numel(FitParams)-2);
        FH = findobj('Type','figure','-and','Name',FigureName);
        if ~isempty(FH)
            figure(FH);
        else
            FH = FFS('Name',FigureName);
        end
        PlotVar = [];
        subH=subplot1(nsub(1),nsub(2));
        for ifit = 1:numel(FitParams)
            if ~any(ifit==[XColID YColID])
                RealPage.(FitParams(ifit).Name) = Pages{1}(:,[ifit XColID YColID]);
                UnstuckedRealPage.(FitParams(ifit).Name) = unstack(RealPage.(FitParams(ifit).Name),FitParams(ifit).Name,'X','AggregationFunction',@mean);
                UnstuckedRealPage.(FitParams(ifit).Name)(:,1) = [];
                GetActualOrientationAction(MFH,UnstuckedRealPage.(FitParams(ifit).Name).Variables,'PlotVar');
                subplot1(ifit);
                PercVal = GetPercentile(UnstuckedRealPage.(FitParams(ifit).Name).Variables,PercFract);
                imh = imagesc(PlotVar,[0 PercVal]);
                subH(ifit).YDir = 'reverse';
                colormap pink, shading interp, axis image;
                title(FitParams(ifit).Name)
                colorbar('southoutside')
                AddGetTableInfo(FH(end),imh,Filters,rows,AllData)
                AddSelectRoi(FH(end),imh,MFH);
                AddDefineBorder(FH(end),imh,MFH);
            end
        end
        delete(subH(numel(FitParams)-2+1:end))
        
        if strcmpi(FitParams(1).FitType,'muamus')
            CheckedID = find([Filters.Checked]);
            if CheckedID
                nactv = numel(Filters(CheckedID).ActualValue);
                [numsub] = numSubplots(nactv);
                for ifit = 1:numel(FitParams)-2
                    tFH = findobj('Type','figure','-and','Name',['GlobalView: ' FitParams(ifit).Name '-' FigureName]);
                    if ~isempty(tFH)
                        FH(end+1) = tFH;
                        figure(FH(end));
                    else
                        FH(end+1) = FFS('Name',['GlobalView: ' FitParams(ifit).Name '-' FigureName]);
                    end
                    subH = subplot1(numsub(1),numsub(2));
                    for av = 1:nactv
                        if ~any(ifit==[XColID YColID])
                            RealName = ([FitParams(ifit).Name num2str(Filters(CheckedID).ActualValue(av))]);
                            RealPage.(RealName) = Pages{av}(:,[ifit XColID YColID]);
                            UnstuckedRealPage.(RealName) = ...
                                unstack(RealPage.((RealName)),FitParams(ifit).Name,'X','AggregationFunction',@mean);
                            UnstuckedRealPage.(RealName)(:,1) = [];
                            subplot1(av);
                            PercVal = GetPercentile(UnstuckedRealPage.(RealName).Variables,PercFract);
                            GetActualOrientationAction(MFH,UnstuckedRealPage.(RealName).Variables,'PlotVar');
                            imh = imagesc(PlotVar,[0 PercVal]);
                            colormap pink, shading interp, axis image;
                            subH(av).YDir = 'reverse';
                            title(RealName)
                            colorbar('southoutside')
                            AddGetTableInfo(FH(end),imh,Filters,rows,AllData)
                            AddSelectRoi(FH(end),imh,MFH);
                            AddDefineBorder(FH(end),imh,MFH);
                        end
                    end
                    delete(subH(nactv+1:end))
                end
            end
        end
        if strcmpi(FitParams(1).FitType,'conc')
            UnstuckedRealPage.HbTot = UnstuckedRealPage.Hb;
            UnstuckedRealPage.HbTot.Variables = ...
                UnstuckedRealPage.Hb.Variables+UnstuckedRealPage.HbO2.Variables;
            UnstuckedRealPage.So2 = UnstuckedRealPage.Hb;
            UnstuckedRealPage.So2.Variables = ...
                UnstuckedRealPage.HbO2.Variables./UnstuckedRealPage.HbTot.Variables;
            ExtraFitParams(1).Name = 'HbTot';
            ExtraFitParams(2).Name = 'So2';
            tFH = findobj('Type','figure','-and','Name',['Extra' FigureName]);
            if ~isempty(tFH)
                FH(end+1) = tFH;
                figure(FH(end));
            else
                FH(end+1) = FFS('Name',['Extra' FigureName]);
            end
            
            subH=subplot1(1,2);
            for ifit = 1:numel(ExtraFitParams)
                if ~any(ifit==[XColID YColID])
                    subplot1(ifit);
                    PercVal = GetPercentile(UnstuckedRealPage.(ExtraFitParams(ifit).Name).Variables,PercFract);
                    GetActualOrientationAction(MFH,UnstuckedRealPage.(ExtraFitParams(ifit).Name).Variables,'PlotVar');
                    imh = imagesc(PlotVar,[0 PercVal]);
                    subH(ifit).YDir = 'reverse';
                    colormap pink, shading interp, axis image;
                    title(ExtraFitParams(ifit).Name)
                    colorbar('southoutside')
                    AddGetTableInfo(FH(end),imh,Filters,rows,AllData)
                    AddSelectRoi(FH(end),imh,MFH);
                    AddDefineBorder(FH(end),imh,MFH);
                end
            end
        end
        
        for ifigs = 1:numel(FH)
            FH(ifigs).UserData.InfoData.Name = {Filters.Name};
            FH(ifigs).UserData.InfoData.Value = {Filters.ActualValue};
            AddInfoEntry(MFH,MFH.UserData.ListFigures,FH(ifigs),FH(ifigs).UserData.InfoData,MFH);
        end
        AddToFigureListStruct(FH,MFH,'data')
    end
end