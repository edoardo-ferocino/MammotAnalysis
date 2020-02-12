function PlotIrf(~,~,MPOBJ)
if ~isfield(MPOBJ.Data,'IrfFilePath')
    DisplayError('No data file','Please load the Data file');
    return
end
%% StartWait
MPOBJ.StartWait;
%% Read data
for infile = 1:MPOBJ.Data.IrfFileNumel
    clearvars('-except','MPOBJ','infile');
    CalcWidthLevel=MPOBJ.Data.CalcWidthLevel;
    [Path ,FileName,~] = fileparts(MPOBJ.Data.IrfFilePath{infile});
    [RawIrf,H,CH,SUBH,~,~,DataSize,DataType]=DatRead(fullfile(Path,FileName),'ForceReading',true);
    [NumRep,NumChan,NumBin]=size(RawIrf);
    if NumBin == 1 && NumChan == 1
        NumBin = NumRep; NumChan = 1; NumRep = 1;
        RawIrf = permute(RawIrf,[2 1]);
    else
        RawIrf = squeeze(sum(RawIrf,1));
    end
    Wavelengths = MPOBJ.Wavelengths;
    if isfield(MPOBJ.Data,'TRSSetFilePath')
        TrsSet = TRSread(MPOBJ.Data.TRSSetFilePath);
    else
        TrsSet.Roi = zeros(numel(Wavelengths),3);
        limits = round(linspace(0,NumBin-1,numel(Wavelengths)+1));
        for ir = 1:numel(Wavelengths)
            TrsSet.Roi(ir,2) = limits(ir);
            TrsSet.Roi(ir,3) = limits(ir+1);
        end
    end
    
    %% Analyze data
    % Curve per channel
    mfigobjs = mfigure('Name',['Curves per channel (all lambda) - ' FileName],'WindowState','maximized','Category','Irf');
    nsub = numSubplots(NumChan);
    tiledlayout(nsub(1),nsub(2),'Padding','compact','TileSpacing','none');
    %subplot1(nsub(1),nsub(2));
    for ich = 1 : NumChan
        nexttile
        %subplot1(ich);
        semilogy(1:NumBin,squeeze(RawIrf(ich,:)));
        xlim([1 NumBin]);
        title(['Channel ',num2str(ich)]);
    end
    mfigobjs.Data.PickData = RawIrf';
    
    % Wavelenghts count rate
    mfigobjs(end+1)=mfigure('Name',['Curves (bkg free) per lambda (all channels) - ' FileName],'WindowState','maximized','Category','Irf');
    nSub = numSubplots(numel(Wavelengths));
    tiledlayout(nSub(1),nSub(2),'Padding','none','TileSpacing','none');
    %subplot1(nSub(1),nSub(2));
    ActAllChannelsCurves = IrfBkgSubtract(RawIrf,str2double(MPOBJ.Graphical.BkgFirst.String):str2double(MPOBJ.Graphical.BkgLast.String),'noneg');
    for iw = 1:numel(Wavelengths)
        Wave(iw).Data = ActAllChannelsCurves(:,TrsSet.Roi(iw,2)+1:TrsSet.Roi(iw,3)+1); %#ok<*AGROW>
        Wave(iw).SummedChannelsData = squeeze(sum(Wave(iw).Data,1));
        [Wave(iw).Width,Wave(iw).Bar] = CalcWidth(Wave(iw).SummedChannelsData(1,:),CalcWidthLevel);
        nexttile;
        %subplot1(iw);
        semilogy(TrsSet.Roi(iw,2)+1:TrsSet.Roi(iw,3)+1,Wave(iw).SummedChannelsData)
        xlim([TrsSet.Roi(iw,2)+1 TrsSet.Roi(iw,3)+1]);
        title(['\lambda = ',num2str(Wavelengths(iw)),' nm']);
    end
    mfigobjs(end).Data.PickData = Wave;
    
    % Actual counts bkg free
    mfigobjs(end+1) = mfigure('Name',['Curves (bkg free, all \lambda, all channel) - ' FileName],'WindowState','maximized','Category','Irf');
    ActAllLambdaAllChannelsCurves = squeeze(sum(ActAllChannelsCurves,1));
    semilogy(1:NumBin,ActAllLambdaAllChannelsCurves);
    xlim([1 NumBin]);
    title('Curves (bkg free, all \lambda, all channel)');
    mfigobjs(end).Data.PickData = ActAllLambdaAllChannelsCurves';
    
    %% "Save" figures
    for ifigs = 1:numel(mfigobjs)
        %     mfigobjs(ifigs).Data.VisualDatData = RawVisualData;
        %     mfigobjs(ifigs).Data.ActualDatData = RawData;
        %     mfigobjs(ifigs).Data.Numel2Pad = size(RawData,1)-size(RawVisualData,1);
        %     mfigobjs(ifigs).Data.CompiledHeaderData = CH;
        %     mfigobjs(ifigs).Data.HeaderData = H;
        %     mfigobjs(ifigs).Data.SubHeaderData = SUBH;
        %     mfigobjs(ifigs).Data.DataType = DataType;
        %     mfigobjs(ifigs).Data.DataSize = DataSize;
        mfigobjs(ifigs).Data.DatInfo.H = H;
        mfigobjs(ifigs).Data.DatInfo.SUBH = SUBH;
        mfigobjs(ifigs).Data.DatInfo.CH = CH;
        mfigobjs(ifigs).Data.DataFilePath=MPOBJ.Data.IrfFilePath{infile};
        %     mfigobjs(ifigs).Data.InfoData.Name = CH.LabelName;
        %     mfigobjs(ifigs).Data.InfoData.Value = CH.LabelContent;
        %     mfigobjs(ifigs).Data.TrsSet = TrsSet;
        mfigobjs(ifigs).Data.FileName = FileName;
        mfigobjs(ifigs).ScaleFactor = abs(CH.LoopDelta(1));
        mfigobjs(ifigs).AddAxesToFigure;
        mfigobjs(ifigs).Show('off');
    end
end
MPOBJ.SelectMultipleFigures([],[],'show');
%% StopWait
MPOBJ.StopWait;
end
