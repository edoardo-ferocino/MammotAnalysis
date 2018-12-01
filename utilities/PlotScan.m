function PlotScan(src,event)
H=guidata(gcbo);
StartWait(H.MFH);
FileName = H.DatFilePath(1:end-4);
[A,~,CH]=DatRead3(FileName,'ForceReading',true);
[NumY,NumX,NumChan,NumBin]=size(A);
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
if isfield(H,'FH')
    H.FH(end+1) = FFS('Name','Count rates per channel');
else
    H.FH = FFS('Name','Count rates per channel');
end
subH = subplot1(2,4);
for ich = 1 : NumChan
    subplot1(ich);
    imagesc(Xv,Yv,CountRatesImage(:,:,ich)./AcqTime);
    colormap pink, shading interp, axis equal;
    %subH(ich).YDir = 'reverse';
    colorbar
    title(num2str(ich));
end

H.FH(end+1) = FFS('Name','Wavelenghts images count rate');
subH = subplot1(2,4);
Wavelengths =[635 680 785 905 930 975 1060];
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
    colorbar
    title(num2str(Wavelengths(iw)));
end
delete(subH(iw+1:end))

H.FH(end+1) = figure('Name','Total count rate image');
CountRatesImageAllChan=sum(CountRatesImage,3);
imagesc(Xv,Yv,CountRatesImageAllChan);
axh = gca; axh.YDir = 'normal';
colormap pink, shading interp, axis equal;
SumChan = squeeze(sum(A,3));
PickCurve(H.FH(end),SumChan);

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
for ifigs = numel(H.FH)-(numAddedFigs-1):numel(H.FH)
   H.FH(ifigs).Visible = 'off';
   H.FH(ifigs).CloseRequestFcn = {@SetFigureInvisible,H.FH(ifigs)};
   AddElementToList(H.ListFigures,H.FH(ifigs));
end
StopWait(H.MFH)
guidata(gcbo,H);
end

