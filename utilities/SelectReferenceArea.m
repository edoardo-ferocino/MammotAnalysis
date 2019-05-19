function SelectReferenceArea(~,~,MFH)
if ~isfield(MFH.UserData,'IrfFilePath')
    errordlg('Please load the SUMMED IRF file','Error');
    return
end
if ~isfield(MFH.UserData,'DatFilePath')
    errordlg('Please load the SUMMED Data file','Error');
    return
end
%% StartWait
StartWait(MFH);
PercFract = 95;
%% Load data
for infile = 1:MFH.UserData.DatFileNumel
    [DatPath ,DatFileName,~] = fileparts(MFH.UserData.DatFilePath{infile});
    [IrfPath ,IrfFileName,~] = fileparts(MFH.UserData.IrfFilePath{:});
    
    RawIrf=DatRead3(fullfile(IrfPath,IrfFileName),'ForceReading',true);
    DimCheck = size(RawIrf);
    if numel(DimCheck)~=2||DimCheck(2)~=1
        errordlg('Please load the SUMMED IRF file','Error');
        StopWait(MFH);
        return
    end
    
    [RawData,H,CH,SUBH,~,~,DataSize,DataType]=DatRead3(fullfile(DatPath,DatFileName),'ForceReading',true);
    [~,~,~,DimCheck] = size(RawData);
    if DimCheck~=1
        errordlg('Please load the SUMMED DATA file','Error');
        StopWait(MFH);
        return
    end
    
    
    [~,~,NumChan,NumBin]=size(RawData);
    if NumBin == 1
        NumBin = NumChan; NumChan = 1;
        RawData = permute(RawData,[1 2 4 3]);
    end
    RawData=flip(RawData,2);
    isVisual = sum(RawData,[2 3 4]) ~= 0;
    RawVisualData = RawData(isVisual,:,:,:);
    RawVisualData = GetActualOrientationAction(MFH,RawVisualData);
    Wavelengths = MFH.UserData.Wavelengths;
    if isfield(MFH.UserData,'TRSSetFilePath')
        TrsSet = TRSread(MFH.UserData.TRSSetFilePath);
    else
        TrsSet.Roi = zeros(numel(Wavelengths),3);
        limits = round(linspace(0,NumBin-1,numel(Wavelengths)+1));
        for ir = 1:numel(Wavelengths)
            TrsSet.Roi(ir,2) = limits(ir);
            TrsSet.Roi(ir,3) = limits(ir+1);
        end
    end
    
    
    % Total count rate
    AcqTime = CH.McaTime;
    AllCounts = sum(RawVisualData,4);
    CountRatesImage = AllCounts./AcqTime;
    FH = CreateOrFindFig(['Choose reference area - ' DatFileName],'WindowState','maximized');
    FH.UserData.FigCategory = 'ReferenceArea';
    CountRatesImageAllChan=sum(CountRatesImage,3);
    subH=subplot1(1,1); subplot1(1);
    PercVal = GetPercentile(CountRatesImageAllChan,PercFract);
    imagesc(CountRatesImageAllChan,[0 PercVal]);
    title('Total CountRate');
    SetAxesAppeareance(subH)
    
    FH.UserData.VisualDatData = RawVisualData;
    FH.UserData.ActualDatData = RawData;
    FH.UserData.ActualIrfData = RawIrf;
    FH.UserData.TrsSet = TrsSet;
    FH.UserData.CompiledHeaderData = CH;
    FH.UserData.Numel2Pad = size(RawData,1)-size(RawVisualData,1);
    FH.UserData.HeaderData = H;
    FH.UserData.SubHeaderData = SUBH;
    FH.UserData.DataType = DataType;
    FH.UserData.DataSize = DataSize;
    FH.UserData.DatFilePath=MFH.UserData.DatFilePath{infile};
    FH.UserData.InfoData.Name = CH.LabelName;
    FH.UserData.InfoData.Value = CH.LabelContent;
    FH.UserData.TrsSet = TrsSet;
    AddToFigureListStruct(FH,MFH,'data',MFH.UserData.DatFilePath{infile});
%     ReferenceCurveS = CalcReferenceGate(SETT.Roi(1:numel(Wavelengths),2:end)+1,IRF,MFH);
%     DataCurveS = ApplyGates(ReferenceCurveS,Data,MFH);
%     PlotGates(DataCurveS,MFH);
end
StopWait(MFH)
end