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

%% Load data
[~,NameFile,~] = fileparts(MFH.UserData.DispDatFilePath.String);
[IrfPath ,IrfFileName,~] = fileparts(MFH.UserData.IrfFilePath);
[DatPath ,DatFileName,~] = fileparts(MFH.UserData.DatFilePath);
IRF_FN = fullfile(IrfPath,IrfFileName);
Data_FN = fullfile(DatPath,DatFileName);
IRF=DatRead3(IRF_FN);
DimCheck = size(IRF);
if numel(DimCheck)~=2||DimCheck(2)~=1
    errordlg('Please load the SUMMED IRF file','Error');
    StopWait(MFH);
    return
end

[A,~,CH]=DatRead3(Data_FN,'ForceReading',true);
MFH.UserData.CompiledHeaderData = CH;
[~,~,~,DimCheck] = size(A);
if DimCheck~=1
    errordlg('Please load the SUMMED DATA file','Error');
    StopWait(MFH);
    return
end

MFH.UserData.CompiledHeaderData = CH;


[~,~,NumChan,NumBin]=size(A);
if NumBin == 1
    NumBin = NumChan; NumChan = 1;
    A = permute(A,[1 2 4 3]);
end
A=flip(A,2);
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

% Total count rate
AcqTime = CH.McaTime;
AllCounts = sum(A,4);
CountRatesImageAllChan = AllCounts./AcqTime;
FH = findobj('Type','figure','-and','Name',['Choose reference area - ' NameFile]);
if ~isempty(FH)
    figure(FH);
else
    FH = FFS('Name',['Choose reference area - ' NameFile]);
end
AddToFigureListStruct(FH,MFH,'side');
subplot1(1,1); subplot1(1);
imh = imagesc(CountRatesImageAllChan);
axh = gca; axh.YDir = 'reverse';
colormap pink, shading interp, axis image;
colorbar
Data = squeeze(sum(A,3));
% AddDefineBorder(FH,imh,MFH)
AddSelectReferenceArea(FH,imh,Data,MFH)
ReferenceCurveS = CalcReferenceGate(SETT.Roi(1:numel(Wavelengths),2:end)+1,IRF,MFH);
DataCurveS = ApplyGates(ReferenceCurveS,Data,MFH);
PlotGates(DataCurveS,MFH);
StopWait(MFH)
end