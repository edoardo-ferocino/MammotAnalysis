function SumChannels(~,~,MFH)
%% ReadFiles
if ~isfield(MFH.UserData,'IrfFilePath')
    errordlg('Please load the NOT SUMMED IRF file','Error');
    return
end
if ~isfield(MFH.UserData,'DatFilePath')
    errordlg('Please load the NOT SUMMED Data file','Error');
    return
end
[IrfPath ,IrfFileName,~] = fileparts(MFH.UserData.IrfFilePath);
[DatPath ,DatFileName,~] = fileparts(MFH.UserData.DatFilePath);
IRF_FN = fullfile(IrfPath,IrfFileName);
Data_FN = fullfile(DatPath,DatFileName);
StartWait(MFH);

is_scan = true;
[IRF,~,CH,SH]=DatRead3(IRF_FN,'compilesub',false);
ndIRF = ndims(IRF);
if ndIRF == 2
    [NumChan,NumBin]=size(IRF);
    NumRep = 0;
elseif ndIRF == 3
    [NumRep,NumChan,NumBin] = size(IRF);
    IRF = squeeze(sum(IRF,1));
else
    return
end
Wavelengths = MFH.UserData.Wavelengths;
warning('off','verbose')
warning('off','backtrace')
if isfield(MFH.UserData,'TRSSetFilePath')
    SETT = TRSread(MFH.UserData.TRSSetFilePath.String);
else
    SETT.Roi = zeros(numel(Wavelengths),3);
    limits = round(linspace(0,NumBin-1,8));
    for ir = 1:numel(Wavelengths)
       SETT.Roi(ir,2) = limits(ir);
       SETT.Roi(ir,3) = limits(ir+1); 
    end
end


POS_IRF_raw = zeros(NumChan,1);
for ich = 1:NumChan
    StartBin = SETT.Roi(1,2)+1;
    StopBin = SETT.Roi(1,3)+1;
    B=squeeze(IRF(ich,StartBin:StopBin));
    [~,~,maxpos] = CalcWidth(B,0.5);
    pos = maxpos;
    pos = pos + StartBin-1;
    POS_IRF_raw(ich) = pos;
end

%% Calc shift for each channel respect to the average position of the first wavelenght
mean_pos = mean(POS_IRF_raw);
shift = mean_pos - POS_IRF_raw;

%% Aplly shifts
IRF_Shifted = zeros(NumChan,NumBin);
for ich = 1:NumChan
    IRF_Shifted(ich,:)=circshift(IRF(ich,:),round(shift(ich)));
end

IRF_Shifted_summed = squeeze(sum(IRF_Shifted,1));

%% Write IRF file
fid_out = fopen([IRF_FN '_summed.DAT'], 'wb');
CH.LoopNum(1) = 1; CH.LoopLast(1) = 1;
Header=CompileHeader(CH);
fwrite(fid_out, Header, 'uint8');
if NumRep
    fwrite(fid_out, SH(1,1,:), 'uint8');
else
    fwrite(fid_out, SH(1,:), 'uint8');
end
curve=IRF_Shifted_summed;
fwrite(fid_out, curve, 'uint32');
warning('\nConversion to long (uint32) required for file: %s', [IRF_FN '_summed']);
fclose(fid_out);


%% Apply shifts to Data
[Data,Header,CH,SH,~] = DatRead3(Data_FN,'forcereading',true);
if is_scan == 1
    [NumY,NumX,NumChan,NumBin]=size(Data);
    Data_Shifted = zeros(NumY,NumX,NumChan,NumBin);
    for iy =1: NumY
        for ix = 1: NumX
            for ich=1:NumChan
                if sum(Data(iy,ix,ich,:))~=0
                    Data_Shifted(iy,ix,ich,:)=circshift(squeeze(Data(iy,ix,ich,:)),round(shift(ich)));
                end
            end
        end
    end
else
    ndData=ndims(Data);
    if ndData == 3
        Data = squeeze(sum(Data,1));
    end
    Data_Shifted = zeros(NumChan,NumBin);
    for ich=1:NumChan
        Data_Shifted(ich,:)=circshift(Data(ich,:),round(shift(ich)));
    end
end

if is_scan
    Data_Shifted_Summed = squeeze(sum(Data_Shifted,3));
else
    Data_Shifted_Summed = squeeze(sum(Data_Shifted,1));
end

%% Write DATA file
fid_out = fopen([Data_FN '_summed.DAT'], 'wb');

if is_scan == 1
    warning('\nConversion to long (uint32) required for file: %s', [Data_FN '_summed']);
    fwrite(fid_out, Header, 'uint8');
    for iy = 1:NumY
        for ix = 1:NumX
            fwrite(fid_out, SH(iy,ix,1,:), 'uint8');
            curve=Data_Shifted_Summed(iy,ix,:);
            fwrite(fid_out, curve, 'uint32');
        end
    end
else
    CH.LoopNum(1) = 1; CH.LoopLast(1) = 1;
    Header=CompileHeader(CH);
    fwrite(fid_out, Header, 'uint8');
    fwrite(fid_out, SH(1,:), 'uint8');
    curve=Data_Shifted_Summed;
    fwrite(fid_out, curve, 'uint32');
end

fclose(fid_out);
msgbox({'Files Created' 'Please load the new files'},'Success','help');
warning('off','verbose')
warning('off','backtrace')
StopWait(MFH)

end