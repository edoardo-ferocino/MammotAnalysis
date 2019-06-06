function PlotIrf(~,~,MFH)
if ~isfield(MFH.UserData,'IrfFilePath')
    errordlg('Please load the Irf file','Error');
    return
end
%% StartWait
StartWait(MFH);

%% Read data


for infile = 1:MFH.UserData.IrfFileNumel
    clearvars('-except','MFH','infile');
    [Path ,FileName,~] = fileparts(MFH.UserData.IrfFilePath{infile});
    
    [RawIrf,H,CH,SUBH,~,~,DataSize,DataType]=DatRead3(fullfile(Path,FileName),'ForceReading',true);
    [NumRep,NumChan,NumBin]=size(RawIrf);
    if NumRep ~= 1 && NumChan == 1
        NumBin = NumRep; NumRep = 1;
        RawIrf = permute(RawIrf,[3 1 2]);
    end
    
    BinVect = 1:NumBin;
    RawIrf = squeeze(sum(RawIrf,1));
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
        % Irf per channel
        FH = CreateOrFindFig(['Irf per channel - ' FileName],'WindowState','maximized');
        FH.UserData.FigCategory = 'IrfChannels';
        nsub = numSubplots(NumChan);
        subplot1(nsub(1),nsub(2),'yscale','log');
        xlim([1 NumBin]);
        for ich = 1 : NumChan
            subplot1(ich);
            semilogy(BinVect,squeeze(RawIrf(ich,:)));
            for iw = 2:numel(Wavelengths)+1
                vline(TrsSet.Roi(iw-1,3)+1,'r','');
            end
            title(num2str(ich));
        end
        
        
        % Wavelenghts count rate
        FH(end+1)=CreateOrFindFig(['Irf Wavelenghts - ' FileName],'WindowState','maximized');
        FH(end).UserData.FigCategory = 'IrfWavelenghts';
        nSub = numSubplots(numel(Wavelengths));
        subH = subplot1(nSub(1),nSub(2),'yscale','log');
        for iw = 1:numel(Wavelengths)
            IrfWave(iw).Data = RawIrf(:,TrsSet.Roi(iw,2)+1:TrsSet.Roi(iw,3)+1);
            for ich = 1:NumChan
                IrfWave(iw).Chan(ich).Data = IrfWave(iw).Data(:,ich,:);
            end
            IrfWave(iw).SumChanData = squeeze(sum(IrfWave(iw).Data,1));
            DataTable(iw) = GetStatistics(IrfWave(iw).SumChanData);
            subplot1(iw);
            semilogy(TrsSet.Roi(iw,2)+1:TrsSet.Roi(iw,3)+1,IrfWave(iw).SumChanData);
            xlim([TrsSet.Roi(iw,2)+1 TrsSet.Roi(iw,3)+1]);
            title(num2str(Wavelengths(iw)));
        end
        delete(subH(iw+1:end))
        
    FH(end+1) = CreateOrFindFig(['Overall Irf - ' FileName],'WindowState','maximized');
    FH(end).UserData.FigCategory = 'IrfTotal';
    AllChannIrf = squeeze(sum(RawIrf,1));
    subH=subplot1(1,1,'yscale','log','min',[0.1 0.25]); subplot1(1);
    semilogy(BinVect,AllChannIrf);
    xlim([1 NumBin]);
    for iw = 2:numel(Wavelengths)+1
        vline(TrsSet.Roi(iw-1,3)+1,'r','');
    end
    DataTableT = struct2table(DataTable); DataTableT.Width = DataTableT.Width.*CH.McaFactor;DataTableVar = DataTableT.Variables';
    tbh = uitable(FH(end),'RowName',fieldnames(DataTable),'ColumnName',num2cell(Wavelengths),'Data',DataTableVar);
    subH.Units = 'pixels'; 
    tbh.ColumnWidth = repelem({subH.Position(3)/numel(Wavelengths)},numel(Wavelengths));
    tbh.Position([3 4]) = tbh.Extent([3 4]);
    tbh.Position(1)=subH.Position(1)-(tbh.Position(3)-subH.Position(3));
    subH.Units = 'normalized';
    title('Total Irf');
    
    %% "Save" figures
    for ifigs = 1:numel(FH)
        FH(ifigs).UserData.ActualDatData = RawIrf;
        FH(ifigs).UserData.CompiledHeaderData = CH;
        FH(ifigs).UserData.HeaderData = H;
        FH(ifigs).UserData.SubHeaderData = SUBH;
        FH(ifigs).UserData.DataType = DataType;
        FH(ifigs).UserData.DataSize = DataSize;
        FH(ifigs).UserData.IrfFilePath=MFH.UserData.IrfFilePath{infile};
        FH(ifigs).UserData.InfoData.Name = CH.LabelName;
        FH(ifigs).UserData.InfoData.Value = CH.LabelContent;
        FH(ifigs).UserData.TrsSet = TrsSet;
        FH(ifigs).UserData.FileName = FileName;
    end
    AddToFigureListStruct(FH,MFH,'data',MFH.UserData.IrfFilePath{infile});
end
%% StopWait
StopWait(MFH)
end
