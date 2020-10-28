function SumChannels(~,~,MPOBJ)
if ~isfield(MPOBJ.Data,'DatFilePath')||~isfield(MPOBJ.Data,'IrfFilePath')
    DisplayError('No data file','Please load the Data file');
    return
end
%% StartWait
MPOBJ.StartWait;
%% Read data
CalcWidthLevel=MPOBJ.Data.CalcWidthLevel;
[Path ,FileName,~] = fileparts(MPOBJ.Data.IrfFilePath{1});
[RawIrf,~,CH,SUBH,~,~,~,~]=DatRead(fullfile(Path,FileName),'ForceReading',true);
[NumRep,NumChan,NumBin]=size(RawIrf);
if NumBin == 1
    NumBin = NumChan; NumChan = NumRep; 
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

%% Analyize and write IRF
StartBin = TrsSet.Roi(1,2)+1;
StopBin = TrsSet.Roi(1,3)+1;
[~,PosIrf] = arrayfun(@(ich) CalcWidth(RawIrf(ich,StartBin:StopBin),CalcWidthLevel),1:NumChan);
RefPos = min(PosIrf);
Shift = round(RefPos - PosIrf);
ShiftedIrf = arrayfun(@(ich) circshift(RawIrf(ich,:),Shift(ich),2),1:NumChan,'UniformOutput',false)';
ShiftedIrf = cell2mat(ShiftedIrf);
ShiftedIrf = sum(ShiftedIrf,1);

NewFilePath = strcat(fullfile(Path,FileName),'_summed.DAT');
fid = fopen(NewFilePath, 'wb');
CH.LoopNum(1) = 1; CH.LoopLast(1) = 1;
H = CompileHeader(CH);
fwrite(fid, H, 'uint8');
fwrite(fid, SUBH(1,1,:), 'uint8');
fwrite(fid, ShiftedIrf, 'uint32');
fclose(fid);

%% Write data
for infile = 1:MPOBJ.Data.DatFileNumel
    clearvars('-except','MPOBJ','infile','Shift');
    [Path ,FileName,~] = fileparts(MPOBJ.Data.DatFilePath{infile});
    [RawData,H,~,SUBH,~,~,~,~]=DatRead(fullfile(Path,FileName),'ForceReading',true);
    [NumY,NumX,NumChan] = size(RawData,1:3);
    DataShifted = zeros(size(RawData));
    for ich = 1:NumChan
        DataShifted(:,:,ich,:) = circshift(RawData(:,:,ich,:),Shift(ich),4);
    end
    DataShifted = squeeze(sum(DataShifted,3));
    
    NewFilePath = strcat(fullfile(Path,FileName),'_summed.DAT');
    fid = fopen(NewFilePath, 'wb');
    fwrite(fid, H, 'uint8');
    for iy = 1:NumY
        for ix = 1:NumX
            fwrite(fid, SUBH(iy,ix,1,:), 'uint8');
            curve = squeeze(DataShifted(iy,ix,:));
            fwrite(fid, curve, 'uint32');
        end
    end
    fclose(fid);
end

msgbox('Files created','Success','Help');

%% StopWait
MPOBJ.StopWait;
end
