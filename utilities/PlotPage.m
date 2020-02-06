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
mfigobj.Data.Fit = Fit;
mfigobj.Data.DataFilePath = Fit.DataFilePath;
mfigobj.Data.FileName = Fit.FileName;
if numel(Page)>1
    nsub(2) = 2;
    nsub(1) = numel(Page);
else
    [nsub]=numSubplots(numel(Fit.Params)-2);
end
% subH=subplot1(nsub(1),nsub(2));
tiledlayout(nsub(1),nsub(2),'TileSpacing','compact','Padding','compact');
isubp = 1;
for ipage = 1:numel(Page)
    for ifit = 1:numel(Fit.Params)
        if ~any(ifit==[XColID YColID])
            RealPage.(Fit.Params(ifit).Name) = Page{ipage}(:,[ifit XColID YColID]);
            UnstuckedRealPage.(Fit.Params(ifit).Name) = unstack(RealPage.(Fit.Params(ifit).Name),Fit.Params(ifit).Name,'X','AggregationFunction',@mean);
            UnstuckedRealPage.(Fit.Params(ifit).Name)(:,1) = [];
            %subplot1(isubp);
            nexttile
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
%delete(subH((numel(Fit.Params)-2)*numel(Page)+1:end));
mfigobj.AddAxesToFigure;
mfigobj.Show('off');
mfigobj.SelectMultipleFigures([],[],'show');
warning('on','MATLAB:table:ModifiedVarnames');
end