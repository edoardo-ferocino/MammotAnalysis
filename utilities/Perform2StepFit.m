function Perform2StepFit(~,~,FH,TwoStepFitTypeH,MFH)
PercFract = 95;
[~,FileName]=fileparts(FH.UserData.FitFilePath);
if ~isfield(MFH.UserData,'SpectraFilePath')
    errordlg('Please load the spectra file','Error');
    return
else
    SpectraFileName = MFH.UserData.SpectraFilePath{:};
    opts = detectImportOptions(SpectraFileName,'FileType','text');
    SpectraData=readtable(SpectraFileName,opts,'ReadVariableNames',1);%,'Delimiter','\t','EndOfLine','\r\n');
    ExtCoeff=SpectraData(ismember(SpectraData.lambda_nm_,MFH.UserData.Wavelengths),2:2+4);
    VarExtCoeff=ExtCoeff.Variables;
end
StartWait(FH);
if contains(FH.Name,'GlobalView:','IgnoreCase',true)
    if contains(FH.Name,'GlobalView: mua','IgnoreCase',true)
        FigureMua = FH;
        Figure2Find = replace(FH.Name,'GlobalView: mua','GlobalView: mus');
        FigureMus = findobj(groot,'type','figure','name',Figure2Find);
    end
    if contains(FH.Name,'GlobalView: mus','IgnoreCase',true)
        FigureMus = FH;
        Figure2Find = replace(FH.Name,'GlobalView: mus','GlobalView: mua');
        FigureMua = findobj(groot,'type','figure','name',Figure2Find);
    end
    
    AxH=findobj(FigureMua,'type','axes');
    for iaxh = 1:numel(AxH)
        Data.Mua(:,:,AxH(iaxh).UserData.WaveID) = AxH(iaxh).UserData.(['mua' num2str(MFH.UserData.Wavelengths(AxH(iaxh).UserData.WaveID))]);
    end
    Data.Mua = permute(Data.Mua,[3 1 2]);
    OrigSize = size(Data.Mua);
    DataResaphed = reshape(Data.Mua,[OrigSize(1) prod(OrigSize(2:3))]);
    FitOpts = optimoptions('lsqlin','Display','off');
    %LowBounds = zeros(size(VarExtCoeff,2),1); UpBounds = [500,500,1000,1000,500];
    UpBounds = [500,500,1000,1000,500];LowBounds = -UpBounds;
    InitCond = zeros(size(VarExtCoeff,2),1);
    for ic = 1:size(DataResaphed,2)
        switch TwoStepFitTypeH.Value
            case 1
            Conc(:,ic)=lsqnonneg(VarExtCoeff,DataResaphed(:,ic));
            case 2
            Conc(:,ic)=lsqlin(VarExtCoeff,DataResaphed(:,ic),VarExtCoeff,DataResaphed(:,ic),[],[],LowBounds,UpBounds,InitCond,FitOpts);
            case 3
            Conc(:,ic)=VarExtCoeff\DataResaphed(:,ic);
        end
    end
    Conc=reshape(Conc,[5 OrigSize(2) OrigSize(3)]);
    Conc = permute(Conc,[2 3 1]);
    
    AxH=findobj(FigureMus,'type','axes');
    for iaxh = 1:numel(AxH)
        Data.Mus(:,:,AxH(iaxh).UserData.WaveID) = AxH(iaxh).UserData.(['mus' num2str(MFH.UserData.Wavelengths(AxH(iaxh).UserData.WaveID))]);
    end
    Data.Mus = permute(Data.Mus,[3 1 2]);
    OrigSize = size(Data.Mus);
    DataResaphed = reshape(Data.Mus,[OrigSize(1) prod(OrigSize(2:3))]);
    InitialGuess = [20 1];
    options = optimoptions('lsqcurvefit','Display','none');
    ScattParams = zeros(2,size(DataResaphed,2));
    figh=uifigure('visible','off');figh.CloseRequestFcn = [];
    movegui(figh); figh.Position(3:4)= [400 100];
    figh.Visible = 'on';
    progh=uiprogressdlg(figh,'Message','Fitting the scattering parameters','Title','Fitting','Indeterminate','on');
    for ic = 1:size(DataResaphed,2)
        if sum(DataResaphed(:,ic))==0
            continue
        end
        FittParams=lsqcurvefit(@MieLaw,InitialGuess,MFH.UserData.Wavelengths,DataResaphed(:,ic),[0 0],[100 10],options);
        ScattParams(:,ic) = FittParams';
    end
    close(progh), figh.CloseRequestFcn = 'closereq';delete(figh)
    ScattParams=reshape(ScattParams,[2 OrigSize(2) OrigSize(3)]);
    ScattParams = permute(ScattParams,[2 3 1]);
    
    SpectralFH = CreateOrFindFig(['2-step fit - ' FileName ' - ' TwoStepFitTypeH.String{TwoStepFitTypeH.Value}],'windowstate','maximized');
    
    nSubs = numSubplots(size(ScattParams,3)+size(Conc,3));
    subH=subplot1(nSubs(1),nSubs(2));
    
    for is = 1:size(Conc,3)
        PercVal = GetPercentile(Conc(:,:,is),PercFract);
        subplot1(is);
        imagesc(subH(is),Conc(:,:,is),[0 PercVal]);
        SetAxesAppeareance(subH(is),'southoutside')
        tempstring = SpectraData.Properties.VariableNames{1+is}; tempstring(strfind(tempstring,'_'):end) = [];
        switch tempstring
            case 'Collagene'
                FieldName = 'Collagen';
            case 'Lip'
                FieldName = 'Lipid';
            case 'Hb'
                FieldName = 'Hb';
            case 'H2O'
                FieldName =  'H20';
            case 'HbO2'
                FieldName = 'HbO2';
        end
        title(FieldName);
        subH(is).UserData.(FieldName) = Conc(:,:,is);
    end
    
    ScattNames = {'A' 'B'};
    for is = size(Conc,3)+(1:size(ScattParams,3))
        ias = is -size(Conc,3);
        PercVal = GetPercentile(ScattParams(:,:,ias),PercFract);
        subplot1(is);
        imagesc(subH(is),ScattParams(:,:,ias),[0 PercVal]);
        SetAxesAppeareance(subH(is),'southoutside')
        title(ScattNames{ias});
        subH(is).UserData.(ScattNames{ias}) = ScattParams(:,:,ias);
    end
    delete(subH(is+1:end));
    SpectralFH.UserData.InfoData = FH.UserData.InfoData;
    SpectralFH.UserData.FitData = FH.UserData.FitData;
    SpectralFH.UserData.Filters = FH.UserData.Filters;
    SpectralFH.UserData.FitFilePath = FH.UserData.FitFilePath;
    SpectralFH.UserData.rows = FH.UserData.rows;
    SpectralFH.UserData.FigCategory = '2-step fit';
    AddToFigureListStruct(SpectralFH,MFH,'data',FH.UserData.FitFilePath);
end
StopWait(FH)
    function Scatt=MieLaw(x,xdata)
        Scatt = x(1).*(xdata./xdata(1)).^(-x(2)); Scatt = Scatt';
    end
end