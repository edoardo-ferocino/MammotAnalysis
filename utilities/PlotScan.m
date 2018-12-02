function PlotScan(src,event)
H=guidata(gcbo);
StartWait(H.MFH);
FileName = H.DatFilePath(1:end-4);
[A,~,CH]=DatRead3(FileName,'ForceReading',true);
H.CompiledHeaderDat = CH;
[NumY,NumX,NumChan,NumBin]=size(A);
if NumBin == 1
    NumBin = NumChan; NumChan = 1;
    A = permute(A,[1 2 4 3]);
end
if isfield(H,'TRSSetFilePath')
    SETT = TRSread(H.TRSSetFilePath);
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
if isfield(H,'FH')
    H.FH(end+1) = FFS('Name','Count rates per channel');
else
    H.FH = FFS('Name','Count rates per channel');
end
nsub = numSubplots(NumChan);
subH = subplot1(nsub(1),nsub(2));
for ich = 1 : NumChan
    subplot1(ich);
    imagesc(Xv,Yv,CountRatesImage(:,:,ich)./AcqTime);
    colormap pink, shading interp, axis equal;
    %subH(ich).YDir = 'reverse';
    if(isXDirReverse), subH(ich).XDir = 'reverse'; end
    colorbar
    title(num2str(ich));
end

H.FH(end+1) = FFS('Name','Wavelenghts images count rate');
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
    Wave(iw).CountsAllChan = squeeze(sum(Wave(iw).Curves,3));
    subplot1(iw);
    imagesc(Xv,Yv,Wave(iw).CountsAllChan./AcqTime);
    colormap pink, shading interp, axis equal;
    %subH(iw).YDir = 'reverse';
    if(isXDirReverse) subH(iw).XDir = 'reverse'; end
    colorbar
    title(num2str(Wavelengths(iw)));
end
delete(subH(iw+1:end))

H.FH(end+1) = FFS('Name','Total count rate image');
CountRatesImageAllChan=sum(CountRatesImage,3);
subplot1(1,1); subplot1(1);
imh = imagesc(Xv,Yv,CountRatesImageAllChan);
%axh = gca; axh.YDir = 'normal';
if(isXDirReverse), axh = gca; axh.XDir = 'reverse'; end
colormap pink, shading interp, axis equal;
colorbar
SumChan = squeeze(sum(A,3));
PickCurve(H.FH(end),SumChan);
AddSelectRoi(H.FH(end),imh);
AddGetDataProfile(H.FH(end),imh);

% figure
%
% figure
% AllChanCopy = AllChan;
% AllChanCopy(AllChanCopy(:)==0)=NaN;
% MeanRows = mean(AllChanCopy,2,'omitnan');
% for ir = 1:NumY
%     plot(1:NumX,repmat(MeanRows(ir),1,NumX)./0.025,1:NumX,AllChanCopy(ir,:)./0.025)
%     title(num2str(ir))
%     pause
% end
numAddedFigs = 3;
MFH = findobj('Type','Figure','-and','Name','Main panel');
for ifigs = numel(H.FH)-(numAddedFigs-1):numel(H.FH)
    H.FH(ifigs).Visible = 'off';
    H.FH(ifigs).CloseRequestFcn = {@SetFigureInvisible,H.FH(ifigs)};
    AddElementToList(H.ListFigures,H.FH(ifigs));
end
if isfield(MFH.UserData,'AllDataFigs')
    MFH.UserData.AllDataFigs(end+1:end+numAddedFigs) = H.FH;
else
    MFH.UserData.AllDataFigs = H.FH;
end
StopWait(H.MFH)
guidata(gcbo,H);
end

