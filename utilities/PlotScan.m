function PlotScan(~,~,MFH)
if ~isfield(MFH.UserData,'DatFilePath')
    errordlg('Please load the Data file','Error');
    return
end
%% StartWait
StartWait(MFH);

%% Read data


for infile = 1:MFH.UserData.DatFileNumel
clearvars('-except','MFH','infile');
PercFract = 95;
MinCountRateTresh = 150000-100000;
[Path ,FileName,~] = fileparts(MFH.UserData.DatFilePath{infile});
OnlinePlotCond = 1;
if MFH.UserData.OnlinePlot.Value
   TempFilePath = [fullfile(Path,FileName),'Online'];
end
while(OnlinePlotCond)
    if MFH.UserData.OnlinePlot.Value
        copyfile([fullfile(Path,FileName),'.DAT'],[TempFilePath,'.DAT']);
        [RawData,H,CH,SUBH,~,~,DataSize,DataType]=DatRead3(fullfile(Path,FileName),'ForceReading',true,'Datatype','uint32');
    else
        [RawData,H,CH,SUBH,~,~,DataSize,DataType]=DatRead3(fullfile(Path,FileName),'ForceReading',true);
    end
    [~,~,NumChan,NumBin]=size(RawData);
    if NumBin == 1
        NumBin = NumChan; NumChan = 1;
        RawData = permute(RawData,[1 2 4 3]);
    end
    RawData=flip(RawData,2);
    isVisual = sum(RawData,[2 3 4],'omitnan') ~= 0;
    RawVisualData = RawData(isVisual,:,:,:);
    RawVisualData = GetActualOrientationAction(MFH,RawVisualData);
    NumRows = size(RawVisualData,1);NumCols = size(RawVisualData,2);
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
    
    
    %% Analyze data
    
    AcqTime = CH.McaTime;
    AllCounts = sum(RawVisualData,4);
    CountRatesImage = AllCounts./AcqTime;
    if (~MFH.UserData.OnlinePlot.Value)
        % Count rate per channel
        FH = CreateOrFindFig(['Count rates per channel - ' FileName],'WindowState','maximized');
        FH.UserData.FigCategory = 'Channels';
        nsub = numSubplots(NumChan);
        subH = subplot1(nsub(1),nsub(2));
        for ich = 1 : NumChan
            subplot1(ich);
            PercVal = GetPercentile(CountRatesImage(:,:,ich),PercFract);
            imagesc(CountRatesImage(:,:,ich),CheckCLims([0 PercVal]));
            title(num2str(ich));
            SetAxesAppeareance(subH(ich));
        end
        
        
        % Wavelenghts count rate
        FH(end+1)=CreateOrFindFig(['Wavelenghts images count rate - ' FileName],'WindowState','maximized');
        FH(end).UserData.FigCategory = 'Wavelenghts';
        nSub = numSubplots(numel(Wavelengths));
        subH = subplot1(nSub(1),nSub(2));
        Bkg = mean(RawVisualData(:,:,:,str2double(MFH.UserData.BkgFirst.String):str2double(MFH.UserData.BkgLast.String)),4);
        ActCounts = RawVisualData - Bkg;
        TotalReferenceMask = ones(size(ActCounts,1),size(ActCounts,2));
        for iw = 1:numel(Wavelengths)
            Wave(iw).Data = ActCounts(:,:,:,TrsSet.Roi(iw,2)+1:TrsSet.Roi(iw,3)+1);
            for ich = 1:NumChan
                Wave(iw).Chan(ich).Data = Wave(iw).Data(:,:,ich,:);
            end
            Wave(iw).SumChanData = squeeze(sum(Wave(iw).Data,3));
            for ir = 1:NumRows
                for ic = 1:NumCols
                    [Wave(iw).Width(ir,ic),Wave(iw).Bar(ir,ic)] = CalcWidth(Wave(iw).SumChanData(ir,ic,:,:),0.5);
                end
            end
            Wave(iw).Curves = Wave(iw).SumChanData;
            Wave(iw).CountsAllChan = squeeze(sum(Wave(iw).Curves,3)); %#ok<*AGROW>
            Wave(iw).Bar = Wave(iw).Bar.*((Wave(iw).CountsAllChan./AcqTime)>MinCountRateTresh);
            Wave(iw).Width = Wave(iw).Width.*((Wave(iw).CountsAllChan./AcqTime)>MinCountRateTresh);
            Wave(iw).Bar(Wave(iw).Bar==0) = nan;
            Wave(iw).Width(Wave(iw).Width==0) = nan;
            Wave(iw).MedianWidth = median(Wave(iw).Width,'all','omitnan');
            Wave(iw).WidthMask = Wave(iw).Width>Wave(iw).MedianWidth;
            Wave(iw).MedianBar = median(Wave(iw).Bar,'all','omitnan');
            Wave(iw).BarMask = Wave(iw).Bar>(Wave(iw).MedianBar*(1-0.10));
            subplot1(iw);
            PercVal = GetPercentile(Wave(iw).CountsAllChan./AcqTime,PercFract);
            imh = imagesc(Wave(iw).CountsAllChan./AcqTime,CheckCLims([0 PercVal]));
            imh.UserData.ReferenceMask = Wave(iw).BarMask;
            TotalReferenceMask = and(TotalReferenceMask,imh.UserData.ReferenceMask);
            title(num2str(Wavelengths(iw)));
            SetAxesAppeareance(subH(iw));
        end
        delete(subH(iw+1:end))
        
        
        % Actual counts bkg free
        FH(end+1) = CreateOrFindFig(['Actual counts bkg free - ' FileName],'WindowState','maximized');
        FH(end).UserData.FigCategory= 'Counts';
        Bkg = mean(RawVisualData(:,:,:,str2double(MFH.UserData.BkgFirst.String):str2double(MFH.UserData.BkgLast.String)),4);
        ActCounts = RawVisualData - Bkg;
        ActCountsAllChan=sum(ActCounts,3);
        ActCountsAllChanImage = sum(ActCountsAllChan,4);
        subH=subplot1(1,1); subplot1(1);
        PercVal = GetPercentile(ActCountsAllChanImage,PercFract);
        imagesc(ActCountsAllChanImage,CheckCLims([0 PercVal]));
        title('Actual counts');
        SetAxesAppeareance(subH)
    end
    % Total count rate
    if (~MFH.UserData.OnlinePlot.Value)
        FH(end+1) = CreateOrFindFig(['Total count rate image - ' FileName],'WindowState','maximized');
    else
         FH = CreateOrFindFig(['Total count rate image Online- ' FileName],'WindowState','maximized');
    end
    FH(end).UserData.FigCategory = 'Counts';
    CountRatesImageAllChan=sum(CountRatesImage,3);
    subH=subplot1(1,1); subplot1(1);
    PercVal = GetPercentile(CountRatesImageAllChan,PercFract);
    imagesc(CountRatesImageAllChan,CheckCLims([0 PercVal]));
    title('Total CountRate');
    SetAxesAppeareance(subH)
    
    if MFH.UserData.OnlinePlot.Value
        dir_info=dir([fullfile(Path,FileName),'.DAT']); 
        if (dir_info.bytes == (764 + prod(CH.LoopNum)*(CH.NumBoard*CH.NumDet)*(CH.SizeSubHeader+CH.McaChannNum*DataSize)))
            OnlinePlotCond = 0;
            delete([TempFilePath,'.DAT']);
        else
            StartWait(FH);
            pause(5);
            StopWait(FH);
        end
    else
        OnlinePlotCond = 0;
    end
end
%% "Save" figures
for ifigs = 1:numel(FH)
    FH(ifigs).UserData.VisualDatData = RawVisualData;
    FH(ifigs).UserData.ActualDatData = RawData;
    FH(ifigs).UserData.Numel2Pad = size(RawData,1)-size(RawVisualData,1);
    FH(ifigs).UserData.CompiledHeaderData = CH;
    FH(ifigs).UserData.HeaderData = H;
    FH(ifigs).UserData.SubHeaderData = SUBH;
    FH(ifigs).UserData.DataType = DataType;
    FH(ifigs).UserData.DataSize = DataSize;
    FH(ifigs).UserData.DatFilePath=MFH.UserData.DatFilePath{infile};
    FH(ifigs).UserData.InfoData.Name = CH.LabelName;
    FH(ifigs).UserData.InfoData.Value = CH.LabelContent;
    FH(ifigs).UserData.TrsSet = TrsSet;
    FH(ifigs).UserData.TotalReferenceMask = TotalReferenceMask;
    FH(ifigs).UserData.FileName = FileName;
end
AddToFigureListStruct(FH,MFH,'data',MFH.UserData.DatFilePath{infile});
end
%% StopWait
StopWait(MFH)
end
