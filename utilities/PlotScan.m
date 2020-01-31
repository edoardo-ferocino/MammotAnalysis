function PlotScan(~,~,MPOBJ)
if ~isfield(MPOBJ.Data,'DatFilePath')
    DisplayError('No data file','Please load the Data file');
    return
end
%% StartWait
MPOBJ.StartWait;
%% Read data
for infile = 1:MPOBJ.Data.DatFileNumel
    clearvars('-except','MPOBJ','infile');
    MinCountRateTresh=MPOBJ.Data.MinCountRateTresh;
    MedianPercentageTreshold=MPOBJ.Data.MedianPercentageTreshold;
    CalcWidthLevel=MPOBJ.Data.CalcWidthLevel;
    [Path ,FileName,~] = fileparts(MPOBJ.Data.DatFilePath{infile});
    OnlinePlotCond = 1;
    if MPOBJ.Graphical.OnlinePlot.Value
        TempFilePath = [fullfile(Path,FileName),'Online'];
    end
    while(OnlinePlotCond)
        if MPOBJ.Graphical.OnlinePlot.Value
            copyfile([fullfile(Path,FileName),'.DAT'],[TempFilePath,'.DAT']);
            [RawData,H,CH,SUBH,~,~,DataSize,DataType]=DatRead(fullfile(Path,FileName),'ForceReading',true,'Datatype','uint32');
        else
            [RawData,H,CH,SUBH,~,~,DataSize,DataType]=DatRead(fullfile(Path,FileName),'ForceReading',true);
        end
        [~,~,NumChan,NumBin]=size(RawData);
        if NumBin == 1
            NumBin = NumChan; NumChan = 1;
            RawData = permute(RawData,[1 2 4 3]);
        end
        RawData=flip(RawData,2);
        isVisual = sum(RawData,[2 3 4],'omitnan') ~= 0;
        RawVisualData = RawData(isVisual,:,:,:);
        NumRows = size(RawVisualData,1);NumCols = size(RawVisualData,2);
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
        AcqTime = CH.McaTime;
        CountsAllLambdas = sum(RawVisualData,4);
        CountRateAllLambdas = CountsAllLambdas./AcqTime;
        if (~MPOBJ.Graphical.OnlinePlot.Value)
            % Count rate per channel
            mfigobjs = mfigure('Name',['Count rate per channel (all lambda) - ' FileName],'WindowState','maximized','Category','Channels');
            nsub = numSubplots(NumChan);
            tiledlayout(nsub(1),nsub(2),'Padding','compact','TileSpacing','none');
            %subplot1(nsub(1),nsub(2));
            for ich = 1 : NumChan
                nexttile
                %subplot1(ich);
                imagesc(CountRateAllLambdas(:,:,ich));
                title(['Channel ',num2str(ich)]);
            end
            mfigobjs.Data.PickData = RawVisualData;
            
            % Wavelenghts count rate
            mfigobjs(end+1)=mfigure('Name',['Count rate (bkg free) per lambda (all channels) - ' FileName],'WindowState','maximized','Category','Wavelengths');
            nSub = numSubplots(numel(Wavelengths));
            tiledlayout(nSub(1),nSub(2));
            %subplot1(nSub(1),nSub(2));
            ActCounts = BkgSubtract(RawVisualData,str2double(MPOBJ.Graphical.BkgFirst.String):str2double(MPOBJ.Graphical.BkgLast.String),'noneg');
            TotalReferenceMask = true(NumRows,NumCols);
            for iw = 1:numel(Wavelengths)
                Wave(iw).Data = ActCounts(:,:,:,TrsSet.Roi(iw,2)+1:TrsSet.Roi(iw,3)+1);
                Wave(iw).SummedChannelsData = squeeze(sum(Wave(iw).Data,3));
                %                 for ich = 1:NumChan
                %                     Wave(iw).Chan(ich).Data = Wave(iw).Data(:,:,ich,:);
                %                 end
                for ir = 1:NumRows
                    for ic = 1:NumCols
                        [Wave(iw).Width(ir,ic),Wave(iw).Bar(ir,ic)] = CalcWidth(Wave(iw).SummedChannelsData(ir,ic,:),CalcWidthLevel);
                    end
                end
                Wave(iw).CountRateAllChan = squeeze(sum(Wave(iw).SummedChannelsData,3))./AcqTime; %#ok<*AGROW>
                Wave(iw).Bar = Wave(iw).Bar.*(Wave(iw).CountRateAllChan>MinCountRateTresh);
                %             Wave(iw).Width = Wave(iw).Width.*(Wave(iw).CountRateAllChan>MinCountRateTresh);
                Wave(iw).Bar(Wave(iw).Bar==0) = nan;
                %             Wave(iw).Width(Wave(iw).Width==0) = nan;
                %             Wave(iw).MedianWidth = median(Wave(iw).Width,'all','omitnan');
                %             Wave(iw).WidthMask = Wave(iw).Width>Wave(iw).MedianWidth;
                Wave(iw).MedianBar = median(Wave(iw).Bar,'all','omitnan');
                Wave(iw).BarMask = Wave(iw).Bar>(Wave(iw).MedianBar*MedianPercentageTreshold);
                nexttile;
                %subplot1(iw);
                imagesc(Wave(iw).CountRateAllChan);
                ReferenceMask = Wave(iw).BarMask;
                TotalReferenceMask = and(TotalReferenceMask,ReferenceMask);
                title(['\lambda = ',num2str(Wavelengths(iw)),' nm']);
            end
            mfigobjs(end).Data.PickData = Wave;
            
            % Actual counts bkg free
            mfigobjs(end+1) = mfigure('Name',['Counts bkg free - ' FileName],'WindowState','maximized','Category','Counts');
            ActCountsAllChan=sum(ActCounts,3);
            ActCountsAllChanAllLambdas = sum(ActCountsAllChan,4);
            imagesc(ActCountsAllChanAllLambdas);
            title('Counts (bkg free, all \lambda, all channel)');
            mfigobjs(end).Data.PickData = ActCountsAllChan;
        end
        % Total count rate
        if (~MPOBJ.Graphical.OnlinePlot.Value)
            mfigobjs(end+1) = mfigure('Name',['Total count rate - ' FileName],'WindowState','maximized','Category','Count rate');
        else
            mfigobjs = mfigure('Name',['Total count rate Online - ' FileName],'WindowState','maximized','Category','Count rate');
        end
        CountRateAllLamdasAllChannels=sum(CountRateAllLambdas,3);
        imagesc(CountRateAllLamdasAllChannels);
        title('Count Rate (all \lambda, all channels)');
        mfigobjs(end).Data.PickData = RawVisualData;
        
        if MPOBJ.Graphical.OnlinePlot.Value
            dir_info=dir([fullfile(Path,FileName),'.DAT']);
            if (dir_info.bytes == (CH.SizeHeader + prod(CH.LoopNum)*(CH.NumSource*CH.NumBoard*CH.NumDet)*(CH.SizeSubHeader+CH.McaChannNum*DataSize)))
                OnlinePlotCond = 0;
                delete([TempFilePath,'.DAT']);
            else
                mfigobjs.StartWait;
                pause(5);
                mfigobjs.StopWait;
            end
        else
            OnlinePlotCond = 0;
        end
    end
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
        mfigobjs(ifigs).Data.DataFilePath=MPOBJ.Data.DatFilePath{infile};
        %     mfigobjs(ifigs).Data.InfoData.Name = CH.LabelName;
        %     mfigobjs(ifigs).Data.InfoData.Value = CH.LabelContent;
        %     mfigobjs(ifigs).Data.TrsSet = TrsSet;
        mfigobjs(ifigs).Data.TotalReferenceMask = TotalReferenceMask;
        %     mfigobjs(ifigs).Data.FileName = FileName;
        mfigobjs(ifigs).ScaleFactor = abs(CH.LoopDelta(1));
        mfigobjs(ifigs).AddAxesToFigure;
        mfigobjs(ifigs).Show('off');
    end
end
MPOBJ.SelectMultipleFigures([],[],'show');
%% StopWait
MPOBJ.StopWait;
end
