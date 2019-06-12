function AddOverlapProfile(parentfigure,object2attach,MFH)
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
uimenu(cmh,'Text','Overlap Picture','CallBack',{@OverlapPicture});

    function OverlapPicture(~,~)
        [FilePath,FileName,~] = fileparts(parentfigure.UserData.DataFilePath);
        FullPathPicture = [fullfile(FilePath,'\Pictures',FileName) '.png'];
        if ~isfile(FullPathPicture)
            [FileName,FilePath,FilterIndex]=uigetfilecustom('*.png');
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
        PixelResolution=5;
        InterpolatedScannedImage=imresize(ZoomedScannedImage, [sx/pixels_per_mm*PixelResolution, sy/pixels_per_mm*PixelResolution] );
        [sx1,sy1]=size(InterpolatedScannedImage);
        % select the reference center in the scanner image (interp1)
        [XC1,YC1]=GetCenter(InterpolatedScannedImage);
        % open image of the breast and interpolate to PixelResoltution
        TName = [tempname,'.tiff'];
        imwrite(uint8((2^8-1)*mat2gray(object2attach.CData,[min(object2attach.CData(:)) max(object2attach.CData(:))])), TName);
        BreastIm = imread(TName);
        delete(TName);
        [sxb,syb]=size(BreastIm);
        InterpolatedBreasIm=imresize(BreastIm, [sxb*PixelResolution, syb*PixelResolution] );
        [sx2,sy2]=size(InterpolatedBreasIm);
        %select reference point in image breast (interp2)
        [XC2,YC2]=GetCenter(InterpolatedBreasIm);
        
        BufferMat=zeros(sx1+2*sx2,sy1+2*sy2);
        BufferMat(sx2:sx1+sx2-1,sy2:sy1+sy2-1)=InterpolatedScannedImage;
        matched=BufferMat(sx2+XC1-XC2:sx2+XC1-XC2+sx2-1+(sx1-sx2),sy2+YC1-YC2:sy2+YC1-YC2+sy2-1);
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
        FigureName = ['Overlapped - ' parentfigure.Name];
        FH = CreateOrFindFig(FigureName);
        imagesc(rgb); grid on;
        axis image; axis on; %colormap pink;
        FH.UserData.FigCategory = 'Overlapped';
        AddToFigureListStruct(FH,MFH,'data',parentfigure.UserData.DataFilePath);
        TName = [tempname,'.tiff'];
        imwrite(rgb,TName);
        imtool(TName);
    end
end