function SetFiltersForFit(FitData,FitParams,Filters,MFH,FitFilePath)
[~,name,~]=fileparts(FitFilePath);
if(strcmpi(FitParams(1).FitType,'conc'))
    PreName = 'Spectral ';
end
if(strcmpi(FitParams(1).FitType,'muamus'))
    PreName = 'Optical Prop ';
end
FigureName = [PreName ' - ' name];
PercFract = 95;
FigFilterName = ['Select filters - ' name];
FigFilterHandle = CreateOrFindFig(FigFilterName,false,'NumberTitle','off','Toolbar','None','MenuBar','none');

addcheckbox = false;
if strcmpi(Filters(1).FitType,'muamus')
    addcheckbox = true;
end

for ifil = 1:numel(Filters)
    ch = CreateContainer(FigFilterHandle,'Units','pixels','Position',[0 FigFilterHandle.Position(4)/numel(Filters)*(ifil-1) FigFilterHandle.Position(3) FigFilterHandle.Position(4)/numel(Filters)],'BorderType','none');
    poph(ifil) = CreatePopUpMenu(ch,'Units','Normalized','String',Filters(ifil).Categories,...
        'Position',[0 0 0.3 0.8],'Value',1); %#ok<*AGROW>
    CreateEdit(ch,'Units','Normalized','Position',...
        [0.4 0.3 0.3 0.5],'String',Filters(ifil).Name,'HorizontalAlignment','left');
    if addcheckbox
        cbh(ifil) = CreateCheckBox(ch,'Units','Normalized','Position',...
            [0.75 0.3 0.3 0.5],'String','Is lambda filter','Callback',{@Checked});
    else
        cbh(ifil) = 0;
    end
end
CreatePushButton(FigFilterHandle,'Units','Normalized','Position',[0.92 0 0.08 0.08],'String','Run','Callback',{@SetFilter,poph,cbh});
movegui(FigFilterHandle,'northeast')
FigFilterHandle.UserData.FitData = FitData;
FigFilterHandle.UserData.FitParams = FitParams;
FigFilterHandle.UserData.FitParams = Filters;
FigFilterHandle.UserData.FitFilePath = FitFilePath;
AddToFigureListStruct(FigFilterHandle,MFH,'data',FitFilePath);
    function Checked(src,~)
        src.UserData.Value = src.Value;
    end
    function SetFilter(~,~,poph,cbh)
        if ~isnumeric(cbh)
            if ~sum([cbh.Value])
               errordlg('Set the lambda filter checkbox');
               return
            end
        end
        StartWait(FigFilterHandle);
        for ip = 1:numel(poph)
            Filters(ip).ActualValue = poph(ip).String{poph(ip).Value};
            Filters(ip).CheckedLambdaFilter = 0;
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
                    Filters(ip).CheckedLambdaFilter = 1;
                end
            end
            FigFilterHandle.UserData.Filters(ip) = Filters(ip);
        end
        [Pages,rows] = CreateActualPage();
        if isempty(Pages)
            StopWait(FigFilterHandle);
            return
        end
        PlotPages(Pages,rows);
        StopWait(FigFilterHandle);
    end
    function [ActualPage,ActualRows] = CreateActualPage()
        cols = sort([FitParams.ColID]);
        nactv = 1;
        if sum([Filters.CheckedLambdaFilter])
            nactv = numel(Filters(logical([Filters.CheckedLambdaFilter])).ActualValue); 
        end
        for av = 1:nactv
            ip = 1; rows = zeros(size(FitData(:,1).Variables,1),1);
            for ifilt = 1:numel(Filters)
                if ~strcmpi(Filters(ifilt).ActualValue,'Any')
                    if Filters(ifilt).CheckedLambdaFilter
                        rows(:,ip)= FitData.(Filters(ifilt).Name) == Filters(ifilt).ActualValue(av);
                    else
                        if strcmpi(Filters(ifilt).Type,'char')
                            rows(:,ip) = strcmpi(FitData.(Filters(ifilt).Name),Filters(ifilt).ActualValue);
                        else
                            rows(:,ip)= FitData.(Filters(ifilt).Name) == Filters(ifilt).ActualValue;
                        end
                    end
                    ip = ip +1;
                else
                    rows(:,ip) = ones(numel(FitData(:,1)),1);
                    ip = ip +1;
                end
            end
            rows = all(rows,2);
%             if sum(rows)==numel(rows)
%                 ActualPage = [];ActualRows = [];
%                 msh = msgbox({'This combination of filters won''t work.' 'Please select a valid filter combination'},'Warning','help');
%                 movegui(msh,'center');
%                 return
%             end
            Page = FitData(:,cols); BPage = Page.Variables;
            BPage(~rows,:) = 0;
            Page.Variables = BPage;
            ActualPage{av}= Page;
            ActualRows(:,av) = rows;
        end
    end
    function PlotPages(Pages,rows)
        XColID = find(strcmpi(Pages{1}.Properties.VariableNames,'X'));
        YColID = find(strcmpi(Pages{1}.Properties.VariableNames,'Y'));
        [nsub]=numSubplots(numel(FitParams)-2);

        if(strcmpi(FitParams(1).FitType,'muamus'))
            FigureName = [PreName ' - ' poph(logical([cbh.Value])).String{poph(logical([cbh.Value])).Value} ' - ' name];
        end

        FH = CreateOrFindFig(FigureName,true);
        subH=subplot1(nsub(1),nsub(2));
        for ifit = 1:numel(FitParams)
            if ~any(ifit==[XColID YColID])
                pageID = 1;
                if(strcmpi(FitParams(1).FitType,'muamus'))
                   pageID = poph(logical([cbh.Value])).Value-1; 
                end
                RealPage.(FitParams(ifit).Name) = Pages{pageID}(:,[ifit XColID YColID]);
                UnstuckedRealPage.(FitParams(ifit).Name) = unstack(RealPage.(FitParams(ifit).Name),FitParams(ifit).Name,'X','AggregationFunction',@mean);
                UnstuckedRealPage.(FitParams(ifit).Name)(:,1) = [];
                subplot1(ifit);
                PlotVar = GetActualOrientationAction(MFH,UnstuckedRealPage.(FitParams(ifit).Name).Variables);
                PlotVar = ApplyBorderToData(MFH,PlotVar);
                PercVal = GetPercentile(PlotVar,PercFract);
                imh = imagesc(subH(ifit),PlotVar,[0 PercVal]);
                SetAxesAppeareance(subH(ifit),'southoutside')
                title(FitParams(ifit).Name)
                AddGetTableInfo(FH(end),imh,Filters,rows(:,pageID),FitData)
            end
        end
        delete(subH(numel(FitParams)-2+1:end))
        
        if strcmpi(FitParams(1).FitType,'muamus')
            CheckedID = find([Filters.CheckedLambdaFilter]);
            if CheckedID
                nactv = numel(Filters(CheckedID).ActualValue);
                [numsub] = numSubplots(nactv);
                for ifit = 1:numel(FitParams)-2
                    FH(end+1) = CreateOrFindFig([PreName ' - GlobalView: ' FitParams(ifit).Name '-' name],true);
                    subH = subplot1(numsub(1),numsub(2));
                    for av = 1:nactv
                        if ~any(ifit==[XColID YColID])
                            RealName = ([FitParams(ifit).Name num2str(Filters(CheckedID).ActualValue(av))]);
                            RealPage.(RealName) = Pages{av}(:,[ifit XColID YColID]);
                            UnstuckedRealPage.(RealName) = ...
                                unstack(RealPage.((RealName)),FitParams(ifit).Name,'X','AggregationFunction',@mean);
                            UnstuckedRealPage.(RealName)(:,1) = [];
                            subplot1(av);
                            PlotVar = GetActualOrientationAction(MFH,UnstuckedRealPage.(RealName).Variables);
                            PlotVar = ApplyBorderToData(MFH,PlotVar);
                            PercVal = GetPercentile(PlotVar,PercFract);
                            imh = imagesc(subH(av),PlotVar,[0 PercVal]);
                            SetAxesAppeareance(subH(av),'southoutside');
                            title(RealName)
                            AddGetTableInfo(FH(end),imh,Filters,rows(:,av),FitData)
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
            ExtraConcParams(1).Name = 'HbTot';
            ExtraConcParams(2).Name = 'So2';
            FH(end+1)=CreateOrFindFig([PreName '- HbTot_So2 -' name],true);
            
            subH=subplot1(1,2);
            for ifit = 1:numel(ExtraConcParams)
                if ~any(ifit==[XColID YColID])
                    subplot1(ifit);
                    PlotVar = GetActualOrientationAction(MFH,UnstuckedRealPage.(ExtraConcParams(ifit).Name).Variables);
                    PlotVar = ApplyBorderToData(MFH,PlotVar);
                    PercVal = GetPercentile(PlotVar,PercFract);
                    imh = imagesc(subH(ifit),PlotVar,[0 PercVal]);
                    SetAxesAppeareance(subH(ifit),'southoutside')
                    title(ExtraConcParams(ifit).Name)
                    AddGetTableInfo(FH(end),imh,Filters,rows,FitData)
                end
            end
        end
        
        for ifigs = 1:numel(FH)
            FH(ifigs).UserData.InfoData.Name = {Filters.Name};
            FH(ifigs).UserData.InfoData.Value = {Filters.ActualValue};
            FH(ifigs).UserData.FitData = FitData;
            FH(ifigs).UserData.Filters = Filters;
            FH(ifigs).UserData.row = rows;
            FH(ifigs).UserData.FitFilePath = FigFilterHandle.UserData.FitFilePath;
            AddInfoEntry(MFH,MFH.UserData.ListFigures,FH(ifigs),MFH);
        end
        AddToFigureListStruct(FH,MFH,'data',FigFilterHandle.UserData.FitFilePath)
    end
end