function SetFiltersForFit(AllData,FitParams,Filters,MFH)
[~,name,~] = fileparts(MFH.UserData.DispFitFilePath.String);
global FigureName;
FigureName = ['Plot fitted values - ' name];
global PercFract
PercFract = 95;
FigFilterName = ['Select filters - ' name];
global FigFilterHandle

FigFilterHandleName = 'SelectFilters';
Obj = MFH.UserData.DispFitFilePath;
if (isfield(Obj.UserData,FigFilterHandleName))
    FigFilterHandle = Obj.UserData.(FigFilterHandleName);
    FigFilterHandle.UserData.(FigFilterHandleName) = Obj.UserData.(FigFilterHandleName);
    figure(FigFilterHandle);
else
    FigFilterHandle = figure('Name',FigFilterName,'Toolbar','None','MenuBar','none','Units','normalized');
    Obj.UserData.(FigFilterHandleName) = FigFilterHandle;
    if ~isfield(MFH.UserData,'SideFigs')
        MFH.UserData.SideFigs = FigFilterHandle;
    else
        MFH.UserData.SideFigs(end+1) = FigFilterHandle;
    end
end
for ifil = 1:numel(Filters)
    ch = CreateContainer(FigFilterHandle,'Position',[0 0.1*(ifil-1) 0.5 1/numel(Filters)],'Visible','on');
    poph(ifil) = CreatePopUpMenu(ch,'Units','Normalized','String',Filters(ifil).Categories,...
        'Position',[0 0 0.3 0.8],'Value',1);
    poph(ifil).UserData.IDFilter = ifil; %#ok<*AGROW>
    CreateEdit(ch,'Units','Normalized','Position',...
        [0.4 0.3 0.3 0.5],'String',Filters(ifil).Name,'HorizontalAlignment','left');
end
movegui(FigFilterHandle,'northeast')


for ifil = 1:numel(Filters)
    poph(ifil).Callback = {@SetFilter,poph};
end

    function SetFilter(~,~,poph)
        StartWait(FigFilterHandle);
        for ip = 1:numel(poph)
            Filters(ip).ActualValue = poph(ip).String{poph(ip).Value};
            if ~strcmpi(Filters(ip).ActualValue,'Any')
                if strcmpi(Filters(ip).Type,'double')
                    Filters(ip).ActualValue = str2double(Filters(ip).ActualValue);
                end
            end
            FigFilterHandle.UserData.Filters(ip) = Filters(ip);
        end
        [Pages,rows] = CreateActualPage();
        PlotPages(Pages,rows);
        StopWait(FigFilterHandle);
    end
    function [Page,rows] = CreateActualPage()
        cols = sort([FitParams.ColID]);
        ip = 1;
        for ifilt = 1:numel(Filters)
            if ~strcmpi(Filters(ifilt).ActualValue,'Any')
                rows(:,ip)= AllData.(Filters(ifilt).Name) == Filters(ifilt).ActualValue;
                ip = ip +1;
            else
                rows(:,ip) = ones(numel(AllData(:,1)),1);
            end
        end
        rows = all(rows,2);
        Page = AllData(rows,cols);
    end
    function PlotPages(Pages,rows)
        XColID = find(strcmpi(Pages.Properties.VariableNames,'X'));
        YColID = find(strcmpi(Pages.Properties.VariableNames,'Y'));
        X.LoopFirst = min(Pages(:,XColID).Variables);
        X.LoopLast = max(Pages(:,XColID).Variables);
        X.Num = (X.LoopLast-X.LoopFirst)+2;
        Y.LoopFirst = min(Pages(:,YColID).Variables);
        Y.LoopLast = max(Pages(:,YColID).Variables);
        Y.Num = (Y.LoopLast-Y.LoopFirst)+1;
        Xv = linspace(X.LoopFirst,X.LoopLast,X.Num);
        Yv = linspace(Y.LoopFirst,Y.LoopLast,Y.Num);
        isYDirReverse = false;isXDirReverse = false;
        if (Y.LoopFirst<Y.LoopLast)
            %             Xv=flip(Xv); isXDirReverse = true;
            isXDirReverse = true;
        end
        if (Y.LoopFirst<Y.LoopLast)
            %             Yv=flip(Yv); isYDirReverse = true;
            isYDirReverse = true;
        end
        if isfield(MFH.UserData,'Xv')
            Xv = MFH.UserData.Xv;Yv = MFH.UserData.Yv;
            isXDirReverse = MFH.UserData.isXDirReverse;
        end
        
        [nsub]=numSubplots(numel(FitParams)-2);
        FH = findobj('Type','figure','-and','Name',FigureName);
        if ~isempty(FH)
            %isfield(MFH.UserData,'AllDataFigs')
            figure(FH);
        else
            FH = FFS('Name',FigureName);
        end
        
        subH=subplot1(nsub(1),nsub(2));
        for ifit = 1:numel(FitParams)
            if ~any(ifit==[XColID YColID])
                RealPage.(FitParams(ifit).Name) = Pages(:,[ifit XColID YColID]);
                UnstuckedRealPage.(FitParams(ifit).Name) = unstack(RealPage.(FitParams(ifit).Name),FitParams(ifit).Name,'X','AggregationFunction',@mean);
                UnstuckedRealPage.(FitParams(ifit).Name)(:,1) = [];
                subplot1(ifit);
                PercVal = GetPercentile(UnstuckedRealPage.(FitParams(ifit).Name).Variables,PercFract);
                if (isXDirReverse)
                    %                     UnstuckedRealPage.(FitParams(ifit).Name).Variables=...
                    %                         flip(UnstuckedRealPage.(FitParams(ifit).Name).Variables,2);
                end
                if (isYDirReverse)
                    %                     UnstuckedRealPage.(FitParams(ifit).Name).Variables=...
                    %                         flip(UnstuckedRealPage.(FitParams(ifit).Name).Variables,1);
                end
                imh = imagesc(Xv,Yv,UnstuckedRealPage.(FitParams(ifit).Name).Variables,[0 PercVal]);
                AddGetTableInfo(FH(end),imh,MFH,Filters,rows,UnstuckedRealPage.(FitParams(ifit).Name),AllData)
                colormap pink, shading interp, axis image;
                if(isYDirReverse), subH(ifit).YDir = 'reverse'; end
                if(isXDirReverse), subH(ifit).XDir = 'reverse'; end
                title(FitParams(ifit).Name)
                colorbar('southoutside')
                AddSelectRoi(FH,imh,MFH);
            end
        end
        delete(subH(numel(FitParams)-2+1:end))
        
        if strcmpi(FitParams(1).FitType,'muamus')
            
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
            FH(end+1) = findobj('Type','figure','-and','Name',['Extra' FigureName]);
            if ~isempty(FH(end))
                %isfield(MFH.UserData,'AllDataFigs')
                figure(FH(end));
            else
                FH(end+1) = FFS('Name',['Extra' FigureName]);
            end
            
            subH=subplot1(1,2);
            for ifit = 1:numel(ExtraFitParams)
                if ~any(ifit==[XColID YColID])
                    subplot1(ifit);
                    PercVal = GetPercentile(UnstuckedRealPage.(ExtraFitParams(ifit).Name).Variables,PercFract);
                    imh = imagesc(Xv,Yv,UnstuckedRealPage.(ExtraFitParams(ifit).Name).Variables,[0 PercVal]);
                    colormap pink, shading interp, axis image;
                    %                 if(isXDirReverse), subH(ifit).YDir = 'reverse'; end
                    if(isXDirReverse), subH(ifit).XDir = 'reverse'; end
                    title(ExtraFitParams(ifit).Name)
                    colorbar('southoutside')
                    AddSelectRoi(FH(end),imh,MFH);
                end
            end
        end
        
        for ifigs = 1:numel(FH)
            %FH(ifigs).Visible = 'off';
            FH(ifigs).CloseRequestFcn = {@SetFigureInvisible,FH(ifigs)};
            AddElementToList(MFH.UserData.ListFigures,FH(ifigs));
            FH(ifigs).UserData.InfoData.Name = {Filters.Name};
            FH(ifigs).UserData.InfoData.Value = {Filters.ActualValue};
            AddInfoEntry(MFH.UserData.ListFigures.UserData.InfoCtxMH,FH(ifigs),FH(ifigs).UserData.InfoData);
        end
        if isfield(MFH.UserData,'AllDataFigs')
            MFH.UserData.AllDataFigs = [MFH.UserData.AllDataFigs FH];
        else
            MFH.UserData.AllDataFigs = FH;
        end
    end
end