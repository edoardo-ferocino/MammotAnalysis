function PlotScan(~,~,MFH)
if ~isfield(MFH.UserData,'DatFilePath')
    errordlg('Please load the Data file','Error');
    return
end
%% StartWait
StartWait(MFH);

%% Read data
[~,NameFile,~] = fileparts(MFH.UserData.DispDatFilePath.String);

[Path ,FileName,~] = fileparts(MFH.UserData.DatFilePath);
[A,~,CH]=DatRead3(fullfile(Path,FileName),'ForceReading',true);
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
%% Analyze data
AcqTime = CH.McaTime;
AllCounts = sum(A,4);

% Count rate per channel
CountRatesImage = AllCounts./AcqTime;
FH = findobj('Type','figure','-and','Name',['Count rates per channel - ' NameFile]);
if ~isempty(FH)
    figure(FH);
else
    FH = FFS('Name',['Count rates per channel - ' NameFile]);
end
                    
nsub = numSubplots(NumChan);
subH = subplot1(nsub(1),nsub(2));
for ich = 1 : NumChan
    subplot1(ich);
    imagesc(CountRatesImage(:,:,ich)./AcqTime);
    colormap pink, shading interp, axis image;
    subH(ich).YDir = 'reverse';
    colorbar
    title(num2str(ich));
end

% Wavelenghts count rate
tFH = findobj('Type','figure','-and','Name',['Wavelenghts images count rate - ' NameFile]);
if ~isempty(tFH)
    FH(end+1) = tFH;
    figure(FH(end));
else
    FH(end+1) = FFS('Name',['Wavelenghts images count rate - ' NameFile]);
end

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
    imh = imagesc(Wave(iw).CountsAllChan./AcqTime);
    colormap pink, shading interp, axis image;
    subH(iw).YDir = 'reverse';
    colorbar
    title(num2str(Wavelengths(iw)));
    AddDefineBorder(FH(end),imh,MFH);
end
delete(subH(iw+1:end))

% Total count rate
tFH = findobj('Type','figure','-and','Name',['Total count rate image - ' NameFile]);
if ~isempty(tFH)
    FH(end+1) = tFH;
    figure(FH(end));
else
    FH(end+1) = FFS('Name',['Total count rate image - ' NameFile]);
end

CountRatesImageAllChan=sum(CountRatesImage,3);
subplot1(1,1); subplot1(1);
imh = imagesc(CountRatesImageAllChan);
axh = gca; axh.YDir = 'reverse';
colormap pink, shading interp, axis image;
colorbar
SumChan = squeeze(sum(A,3));
AddPickCurve(FH(end),imh,SumChan,MFH);
AddSelectRoi(FH(end),imh,MFH);
AddGetDataProfile(FH(end),imh,MFH);
AddDefineBorder(FH(end),imh,MFH);

%% Set figures properties
for ifigs = 1:numel(FH)
    FH(ifigs).Visible = 'off';
    FH(ifigs).CloseRequestFcn = {@SetFigureInvisible,FH(ifigs)};
    AddElementToList(MFH.UserData.ListFigures,FH(ifigs));
end
AddToFigureListStruct(FH,MFH,'data');
%% StopWait
StopWait(MFH)
end

