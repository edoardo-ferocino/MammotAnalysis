function PlotScan(~,~,MFH)
H=guidata(gcbo);
StartWait(MFH);
[~,NameFile,~] = fileparts(MFH.UserData.DispDatFilePath.String);
FileName = H.DatFilePath(1:end-4);
[A,~,CH]=DatRead3(FileName,'ForceReading',true);
H.CompiledHeaderDat = CH;
[~,~,NumChan,NumBin]=size(A);
if NumBin == 1
    NumBin = NumChan; NumChan = 1;
    A = permute(A,[1 2 4 3]);
end
if isfield(MFH.UserData,'TRSSetFilePath')
    SETT = TRSread(MFH.UserData.TRSSetFilePath);
else
    SETT.Roi = zeros(7,3);
    limits = round(linspace(0,NumBin-1,8));
    for ir = 1:7
        SETT.Roi(ir,2) = limits(ir);
        SETT.Roi(ir,3) = limits(ir+1);
    end
end
if (CH.LoopFirst(1)<CH.LoopLast(1))
    A=flip(A,2);
end
AcqTime = CH.McaTime;
AllCounts = sum(A,4);

CountRatesImage = AllCounts./AcqTime;
Xv = linspace(CH.LoopFirst(1),CH.LoopLast(1),CH.LoopNum(1));
Yv = linspace(CH.LoopFirst(2),CH.LoopLast(2),CH.LoopNum(2));
if (CH.LoopFirst(1)<CH.LoopLast(1))
    Xv=flip(Xv); isXDirReverse = true;
else
    isXDirReverse = false;
end
MFH.UserData.isXDirReverse = isXDirReverse;
MFH.UserData.Xv = Xv;MFH.UserData.Yv = Yv;
FH = FFS('Name',['Count rates per channel - ' NameFile]);
nsub = numSubplots(NumChan);
subH = subplot1(nsub(1),nsub(2));
for ich = 1 : NumChan
    subplot1(ich);
    imagesc(Xv,Yv,CountRatesImage(:,:,ich)./AcqTime);
    colormap pink, shading interp, axis image;
    %subH(ich).YDir = 'reverse';
    if(isXDirReverse), subH(ich).XDir = 'reverse'; end
    colorbar
    title(num2str(ich));
end

FH(end+1) = FFS('Name',['Wavelenghts images count rate - ' NameFile]);
Wavelengths =[635 680 785 905 930 975 1060];
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
    imagesc(Xv,Yv,Wave(iw).CountsAllChan./AcqTime);
    colormap pink, shading interp, axis image;
    %subH(iw).YDir = 'reverse';
    if(isXDirReverse), subH(iw).XDir = 'reverse'; end
    colorbar
    title(num2str(Wavelengths(iw)));
end
delete(subH(iw+1:end))

FH(end+1) = FFS('Name',['Total count rate image - ' NameFile]);
CountRatesImageAllChan=sum(CountRatesImage,3);
subplot1(1,1); subplot1(1);
imh = imagesc(Xv,Yv,CountRatesImageAllChan);
%axh = gca; axh.YDir = 'normal';
if(isXDirReverse), axh = gca; axh.XDir = 'reverse'; end
colormap pink, shading interp, axis image;
colorbar
SumChan = squeeze(sum(A,3));
AddPickCurve(FH(end),imh,SumChan,MFH);
AddSelectRoi(FH(end),imh,MFH);
AddGetDataProfile(FH(end),imh,MFH);

for ifigs = 1:numel(FH)
    FH(ifigs).Visible = 'off';
    FH(ifigs).CloseRequestFcn = {@SetFigureInvisible,FH(ifigs)};
    AddElementToList(MFH.UserData.ListFigures,FH(ifigs));
end
if isfield(MFH.UserData,'AllDataFigs')
    MFH.UserData.AllDataFigs = [MFH.UserData.AllDataFigs FH];
else
    MFH.UserData.AllDataFigs = FH;
end
StopWait(MFH)
guidata(gcbo,H);
end

