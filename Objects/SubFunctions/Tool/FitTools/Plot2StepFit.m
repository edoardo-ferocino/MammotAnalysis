function Plot2StepFit(mfigobj,conc,sca)
FigureName = ['Spectral Fitted - ' mfigobj.Data.Fit.FileName];
Category = 'SpectralFitted';
newmfigobj = mfigure('Name',FigureName,'Category',Category,'WindowState','maximized');
newmfigobj.Data = mfigobj.Data;
newmfigobj.Data.Fit.Type = 'Spectral';
CompNames = {'Hb' 'HbO2' 'Lipid' 'Water' 'Collagen' 'A' 'B' 'HbTot' 'SO2'};
Data = vertcat(conc,sca);
for ic = 1:numel(CompNames)-2
   FitData.(CompNames{ic}) = squeeze(Data(ic,:,:)); 
end
FitData.HbTot = FitData.Hb+FitData.HbO2;
FitData.SO2 = FitData.HbO2./FitData.HbTot .* 100;
FitData.SO2(isnan(FitData.SO2))=0;
FitData = orderfields(FitData,[1 2 3 4 5 8 9 6 7]);
nsub=numSubplots(numel(fieldnames(FitData)));
tiledlayout(nsub(1),nsub(2),'TileSpacing','none','Padding','none');
for ifit = 1:numel(fieldnames(FitData))
    nexttile
    imagesc(FitData.(CompNames{ifit}));
    title(CompNames{ifit})
end

newmfigobj.AddAxesToFigure;
newmfigobj.Hide;
newmfigobj.SelectMultipleFigures([],[],'show');
end