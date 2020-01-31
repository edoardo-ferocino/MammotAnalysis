function Overlap = OverlapDrawing(mtoolobj,Overlap)
PixelResolution=5;
if isempty(Overlap)
    [FilePath,FileName,~] = fileparts(mtoolobj.Parent.Data.DataFilePath);
    FullPathPicture = [fullfile(FilePath,'Scan',FileName) '.png'];
    if ~isfile(FullPathPicture)
        [FileName,FilePath,FilterIndex]=uigetfilecustom({'*.png','Scan'});
        if FilterIndex==0, return; end
        FullPathPicture = [FilePath,FileName];
    end
    ScannedImage = imread(FullPathPicture);
    thresold=100;
    tScannedImage=ScannedImage<thresold;
    %Select the region of interest
    ZoomedScannedImage=SetRegionOfInterest(tScannedImage);
    %Select the reference points
    [pixels_per_mm]=SelectReferencePoints(ZoomedScannedImage);
    %interpolate Scanner image selection at 30 pixels per mm
    [sx,sy]=size(ZoomedScannedImage);
    InterpolatedScannedImage=imresize(ZoomedScannedImage, [sx/pixels_per_mm, sy/pixels_per_mm].*PixelResolution);
    [sx1,sy1]=size(InterpolatedScannedImage);
    % select the reference center in the scanner image (interp1)
    [XC1,YC1]=GetCenter(InterpolatedScannedImage);
    % open image of the breast and interpolate to PixelResoltution
end
TName = [tempname,'.tiff'];
TrimCoord=ShowTrimmerPoint(mtoolobj.Parent.Data.DataFilePath,mtoolobj.Axes.ImageData);
imwrite(uint8((255)*mat2gray(mtoolobj.Axes.ImageData,mtoolobj.Axes.CLim)), TName);
BreastIm = imread(TName);
delete(TName);
[sxb,syb]=size(BreastIm);
if mtoolobj.Parent.ScaleFactor==1
    temp = inputdlg('Insert # acq per step');
    pixels_per_mm = 1/str2double(temp{1});
else
    pixels_per_mm = 1/mtoolobj.Parent.ScaleFactor;
end
InterpolatedBreasIm=imresize(BreastIm, [sxb/pixels_per_mm, syb/pixels_per_mm].*PixelResolution,'Method','nearest');
if isempty(Overlap)
    [sx2,sy2]=size(InterpolatedBreasIm);
    %select reference point in image breast (interp2)
    if isempty(TrimCoord)
        [XC2,YC2]=GetCenter(InterpolatedBreasIm);
    else
        YC2 = TrimCoord/pixels_per_mm*PixelResolution;
        XC2 = 1/pixels_per_mm*PixelResolution;
        XC2 = 0;
    end
    BufferMat=zeros(sx1+2*sx2,sy1+2*sy2);
    BufferMat(sx2:sx1+sx2-1,sy2:sy1+sy2-1)=InterpolatedScannedImage;
    matched=BufferMat(sx2+XC1-XC2:sx2+XC1-XC2-1+(sx1-XC1+XC2),sy2+YC1-YC2:sy2+YC1-YC2+sy2-1);
    Overlap.matched = matched;
else
    matched=Overlap.matched;
end
% the two images have now the same size:
% 'matched' is the image of the scanner
% 'interp2' is the image of the breast
%create rgb image of breast with pink colors and set the "black"
%color
map=pink(255);map(1,:) = [ 0 0 0];
rgb=ind2rgb(InterpolatedBreasIm,map);
%color in red the pixels correspondinf to the scanner image ('matched')
indexes=matched>0;
rgb=padarray(rgb,[abs(size(indexes,1)-size(rgb,1)),0,0],0,'post');
rgb([indexes,indexes,indexes])=0; %set the rgb image to 0 in the selected values
rgb(indexes)=255; %set the red pixel to 255 in the selected values
%rgb = imresize(rgb,[sxb syb],'Method','nearest');
% FigureName = ['Overlapped - ' mtoolobj.Parent.Name];
% mfigobj = mfigure('Name',FigureName,'WindowState','maximized','Category','Overlapped');
mtoolobj.Axes.ImageData = rgb;
% ah.XTickLabel=cellstr(num2str(cellfun(@str2num,ah.XTickLabel,'UniformOutput',1)*pixels_per_mm/PixelResolution));
% ah.YTickLabel=cellstr(num2str(cellfun(@str2num,ah.YTickLabel,'UniformOutput',1)*pixels_per_mm/PixelResolution));
mtoolobj.Axes.axes.XTickLabel=cellstr(num2str(mtoolobj.Axes.axes.XTick'*pixels_per_mm/PixelResolution*mtoolobj.Parent.ScaleFactor));
mtoolobj.Axes.axes.YTickLabel=cellstr(num2str(mtoolobj.Axes.axes.YTick'*pixels_per_mm/PixelResolution*mtoolobj.Parent.ScaleFactor));

    function TrimmCoord=ShowTrimmerPoint(DatFilePath,Data)
        TrimmCoord = [];
        [Path,FileName,~]=fileparts(DatFilePath);
        InfoFilePath = fullfile(Path,[FileName,'_info.txt']);
        if ~isfile(InfoFilePath)
            [FileName,Path,FilterIndex]=uigetfilecustom({'*.txt;','Select info file'});
            if FilterIndex == 0, return, end
            InfoFilePath = [Path,FileName];
        end
        InfoScan=readtable(InfoFilePath);
        TrimmCoord = find(Data(1,:)~=0,1,'last')-InfoScan.Var2(contains(InfoScan.Var1,'border'));
        if isempty(TrimmCoord)
            errordlg({['Error reading:' fullfile(Path,[FileName,'_info.txt'])],'No "Border" entry found'},'Error');
            return
        end
        %hold on
        %AxH = ancestor(object2attach,'axes');
        %plot(AxH,TrimmCoord,1,'Marker','square','MarkerFaceColor','red','MarkerSize',5);
        %%text(AxH,TriggCoord,5,num2str(TriggCoord),'FontSize',15);
        %hold off
    end
end