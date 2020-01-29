function PlotPage(Page,Fit)
warning('off','MATLAB:table:ModifiedVarnames');
XColID = find(strcmpi(Page{1}.Properties.VariableNames,'X'));
YColID = find(strcmpi(Page{1}.Properties.VariableNames,'Y'));

if(strcmpi(Fit.Type,'OptProps'))
    FigureName = ['Optical properties - ' Fit.FileName];
    Category = 'Mua&Mus';
    SelWave = Fit.Filters(vertcat(Fit.Filters.LambdaFilter)).SelectedCategory;
else
    FigureName = ['Spectral - ' Fit.FileName];
    Category = 'Spectral';
end
mfigobj = mfigure('Name',FigureName,'Category',Category,'WindowState','maximized');
mfigobj.ScaleFactor = 2;
if numel(Page)>1
    nsub(2) = 2;
    nsub(1) = numel(Page);
else
    [nsub]=numSubplots(numel(Fit.Params)-2);
end
subH=subplot1(nsub(1),nsub(2));
isubp = 1;
for ipage = 1:numel(Page)
    for ifit = 1:numel(Fit.Params)
        if ~any(ifit==[XColID YColID])
            RealPage.(Fit.Params(ifit).Name) = Page{ipage}(:,[ifit XColID YColID]);
            UnstuckedRealPage.(Fit.Params(ifit).Name) = unstack(RealPage.(Fit.Params(ifit).Name),Fit.Params(ifit).Name,'X','AggregationFunction',@mean);
            UnstuckedRealPage.(Fit.Params(ifit).Name)(:,1) = [];
            subplot1(isubp);
            isubp = isubp+1;
            PlotVar = UnstuckedRealPage.(Fit.Params(ifit).Name).Variables;
            VisualPlotVar = PlotVar(sum(PlotVar,2,'omitnan')~=0,:);
            imagesc(VisualPlotVar);
            if strcmpi(Fit.Type,'OptProps')
                titlename = [Fit.Params(ifit).Name ', \lambda = ',num2str(SelWave(ipage))];
            else
                titlename = Fit.Params(ifit).Name;
            end
            title(titlename)
        end
    end
end
delete(subH((numel(Fit.Params)-2)*numel(Page)+1:end));
mfigobj.AddAxesToFigure;
warning('on','MATLAB:table:ModifiedVarnames');

return

for ifigs = 1:numel(FH)
    FH(ifigs).UserData.InfoData.Name = {Filters.Name};
    FH(ifigs).UserData.InfoData.Value = {Filters.ActualValue};
    FH(ifigs).UserData.FitData = FitData;
    FH(ifigs).UserData.Filters = Filters;
    FH(ifigs).UserData.FitFilePath = FigFilterHandle.UserData.FitFilePath;
    if strcmpi(Filters(1).FitType,'OptProps')
        if isempty(findobj(FH(ifigs),'type','pushbutton','string','2-step fit'))
            TwoStepFitTypeH=CreatePopUpMenu(FH(ifigs),'String',{'LSQNONNEG','LSQLIN','BACKSLASH'},'Units','Normalized',...
                'Position',[0.05 0 0.05 0.05]);
            CreatePushButton(FH(ifigs),'String','2-step fit','Units','Normalized',...
                'Position',[0 0 0.05 0.05],'CallBack',{@Perform2StepFit,FH(ifigs),TwoStepFitTypeH,MFH});
        end
    end
end

end