function PlotPage(Page,Fit)
warning('off','MATLAB:table:ModifiedVarnames');
XColID = find(strcmpi(Page{1}.Properties.VariableNames,'X'));
YColID = find(strcmpi(Page{1}.Properties.VariableNames,'Y'));

if(strcmpi(Fit.Type,'OptProps'))
    FigureName = ['Optical properties - ' Fit.FileName];
    Category = 'Mua&Mus';
    SelWave = Fit.Filters(vertcat(Fit.Filters.LambdaFilter)).SelectedCategory;
elseif(strcmpi(Fit.Type,'Spectral'))
    FigureName = ['Spectral - ' Fit.FileName];
    Category = 'Spectral';
elseif(strcmpi(Fit.Type,'Dmua'))
    FigureName = ['Dmua - ' Fit.FileName];
    Category = 'Dmua';
    SelWave = Fit.Filters(vertcat(Fit.Filters.LambdaFilter)).SelectedCategory;
end
mfigobj = mfigure('Name',FigureName,'Category',Category,'WindowState','maximized');
mfigobj.Data.Fit = Fit;
mfigobj.Data.DataFilePath = Fit.DataFilePath;
mfigobj.Data.FileName = Fit.FileName;
if numel(Page)>1 && ~strcmpi(Fit.Type,'Dmua')
    nsub(2) = 2;
    nsub(1) = numel(Page);
elseif numel(Page) > 1 && strcmpi(Fit.Type,'Dmua')
    nsub(2) = numel(Page);
    nsub(1) = 1;
else
    [nsub]=numSubplots(numel(Fit.Params)-2);
end
% subH=subplot1(nsub(1),nsub(2));
tiledlayout(nsub(1),nsub(2),'TileSpacing','none','Padding','none');
isubp = 1;
for ipage = 1:numel(Page)
    for ifit = 1:numel(Fit.Params)
        if ~any(ifit==[XColID YColID])
            RealPage.(Fit.Params(ifit).Name) = Page{ipage}(:,[ifit XColID YColID]);
            UnstuckedRealPage.(Fit.Params(ifit).Name) = unstack(RealPage.(Fit.Params(ifit).Name),Fit.Params(ifit).Name,'X','AggregationFunction',@mean);
            UnstuckedRealPage.(Fit.Params(ifit).Name)(:,1) = [];
            %subplot1(isubp);
            nexttile
            PlotVar = UnstuckedRealPage.(Fit.Params(ifit).Name).Variables;
            VisualPlotVar = PlotVar(sum(PlotVar,2,'omitnan')~=0,:);
            if ~isfield(mfigobj.Data,'Border')
               mfigobj.Data.Border = find(VisualPlotVar(1,:)~=0,1,'last');
            end
            imh(isubp)=imagesc(VisualPlotVar);
            isubp = isubp+1;
            if ~strcmpi(Fit.Type,'Spectral')
                titlename = [Fit.Params(ifit).Name ', \lambda = ',num2str(SelWave(ipage))];
            else
                titlename = Fit.Params(ifit).Name;
            end
            title(titlename)
        end
    end
end
px = -inf; py = -inf;
for ip = 1:isubp-1
   [nx,ny]=size(imh(ip).CData);
   px = max(px,nx);
   py = max(py,ny);
end
for ip = 1:isubp-1
   imh(ip).CData = padarray(imh(ip).CData,px-size(imh(ip).CData,1),0,'post');
   imh(ip).CData = padarray(imh(ip).CData,[0 py-size(imh(ip).CData,2)],0,'both');
end
mfigobj.AddAxesToFigure;
mfigobj.Hide;
mfigobj.SelectMultipleFigures([],[],'show');
warning('on','MATLAB:table:ModifiedVarnames');
end