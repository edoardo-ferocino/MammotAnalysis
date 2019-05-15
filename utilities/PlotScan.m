function PlotScan(~,~,MFH)
if ~isfield(MFH.UserData,'DatFilePath')
    errordlg('Please load the Data file','Error');
    return
end
%% StartWait
StartWait(MFH);

%% Read data
PercFract = 95;

for infile = 1:MFH.UserData.DatFileNumel
[Path ,FileName,~] = fileparts(MFH.UserData.DatFilePath{infile});
OnlinePlotCond = 1;
if MFH.UserData.OnlinePlot.Value
   TempFilePath = [fullfile(Path,FileName),'Online'];
end
while(OnlinePlotCond)
    if MFH.UserData.OnlinePlot.Value
        copyfile([fullfile(Path,FileName),'.DAT'],[TempFilePath,'.DAT']);
        [A,H,CH,SUBH,~,~,DataSize,DataType]=DatRead3(fullfile(Path,FileName),'ForceReading',true,'Datatype','ushort');
    else
        [A,H,CH,SUBH,~,~,DataSize,DataType]=DatRead3(fullfile(Path,FileName),'ForceReading',true);
    end
    [~,~,NumChan,NumBin]=size(A);
    if NumBin == 1
        NumBin = NumChan; NumChan = 1;
        A = permute(A,[1 2 4 3]);
    end
    A=flip(A,2);
    A = GetActualOrientationAction(MFH,A);
    Wavelengths = MFH.UserData.Wavelengths;
    if isfield(MFH.UserData,'TRSSetFilePath')
        SETT = TRSread(MFH.UserData.TRSSetFilePath);
    else
        SETT.Roi = zeros(numel(Wavelengths),3);
        limits = round(linspace(0,NumBin-1,numel(Wavelengths)+1));
        for ir = 1:numel(Wavelengths)
            SETT.Roi(ir,2) = limits(ir);
            SETT.Roi(ir,3) = limits(ir+1);
        end
    end
    MFH.UserData.SETT = SETT;
    
    %% Analyze data
    
    AcqTime = CH.McaTime;
    AllCounts = sum(A,4);
    CountRatesImage = AllCounts./AcqTime;
    if (~MFH.UserData.OnlinePlot.Value)
        % Count rate per channel
        FH = CreateOrFindFig(['Count rates per channel - ' FileName],true);
        nsub = numSubplots(NumChan);
        subH = subplot1(nsub(1),nsub(2));
        for ich = 1 : NumChan
            subplot1(ich);
            PercVal = GetPercentile(CountRatesImage(:,:,ich),PercFract);
            imagesc(CountRatesImage(:,:,ich),[0 PercVal]);
            title(num2str(ich));
            SetAxesAppeareance(subH(ich));
        end
        
        
        % Wavelenghts count rate
        FH(end+1)=CreateOrFindFig(['Wavelenghts images count rate - ' FileName],true);
        
        nSub = numSubplots(numel(Wavelengths));
        subH = subplot1(nSub(1),nSub(2));
        for iw = 1:numel(Wavelengths)
            Wave(iw).Data = A(:,:,:,SETT.Roi(iw,2)+1:SETT.Roi(iw,3)+1);
            for ich = 1:NumChan
                Wave(iw).Chan(ich).Data = Wave(iw).Data(:,:,ich,:);
            end
            Wave(iw).SumChanData = squeeze(sum(Wave(iw).Data,3));
            Wave(iw).Curves = Wave(iw).SumChanData;
            Wave(iw).CountsAllChan = squeeze(sum(Wave(iw).Curves,3)); %#ok<*AGROW>
            subplot1(iw);
            PercVal = GetPercentile(Wave(iw).CountsAllChan./AcqTime,PercFract);
            imagesc(Wave(iw).CountsAllChan./AcqTime,[0 PercVal]);
            title(num2str(Wavelengths(iw)));
            SetAxesAppeareance(subH(iw));
        end
        delete(subH(iw+1:end))
        
        
        % Actual counts bkg free
        FH(end+1) = CreateOrFindFig(['Actual counts bkg free - ' FileName],true);
        Bkg = mean(A(:,:,:,1:20),4);
        ActCounts = A - Bkg;
        ActCountsAllChan=sum(ActCounts,3);
        ActCountsAllChanImage = sum(ActCountsAllChan,4);
        subH=subplot1(1,1); subplot1(1);
        PercVal = GetPercentile(ActCountsAllChanImage,PercFract);
        imagesc(ActCountsAllChanImage,[0 PercVal]);
        title('Actual counts');
        SetAxesAppeareance(subH)
    end
    % Total count rate
    if (~MFH.UserData.OnlinePlot.Value)
        FH(end+1) = CreateOrFindFig(['Total count rate image - ' FileName],true);
    else
         FH(end+1) = CreateOrFindFig(['Total count rate image Online- ' FileName],true);
    end
    CountRatesImageAllChan=sum(CountRatesImage,3);
    subH=subplot1(1,1); subplot1(1);
    PercVal = GetPercentile(CountRatesImageAllChan,PercFract);
    imagesc(CountRatesImageAllChan,[0 PercVal]);
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
    FH(ifigs).UserData.DatData = A;
    FH(ifigs).UserData.CompiledHeaderData = CH;
    FH(ifigs).UserData.HeaderData = H;
    FH(ifigs).UserData.SubHeaderData = SUBH;
    FH(ifigs).UserData.DataType = DataType;
    FH(ifigs).UserData.DataSize = DataSize;
    FH(ifigs).UserData.DatFilePath=MFH.UserData.DatFilePath{infile};
    FH(ifigs).UserData.InfoData.Name = CH.LabelName;
    FH(ifigs).UserData.InfoData.Value = CH.LabelContent;
end
AddToFigureListStruct(FH,MFH,'data',MFH.UserData.DatFilePath{infile});
end
%% StopWait
StopWait(MFH)
end
