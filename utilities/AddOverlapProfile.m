function AddOverlapProfile(parentfigure,object2attach,MFH)
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
mmh=uimenu(cmh,'Text','Overlap Picture');
uimenu(mmh,'Text','Overlap','CallBack',{@OverlapPicture});
uimenu(mmh,'Text','Overlap to all','CallBack',{@CreateLinkDataFigure});

    function OverlapPicture(~,~)
        [FilePath,FileName,~] = fileparts(parentfigure.UserData.DataFilePath);
        FullPathPicture = [fullfile(FilePath,'Scan',FileName) '.png'];
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
        InterpolatedScannedImage=imresize(ZoomedScannedImage, [sx/pixels_per_mm*PixelResolution, sy/pixels_per_mm*PixelResolution]);
        [sx1,sy1]=size(InterpolatedScannedImage);
        % select the reference center in the scanner image (interp1)
        [XC1,YC1]=GetCenter(InterpolatedScannedImage);
        % open image of the breast and interpolate to PixelResoltution
        TName = [tempname,'.tiff'];
        TrimCoord=ShowTrimmerPoint;
        AxH = ancestor(object2attach,'axes');
        imwrite(uint8((255)*mat2gray(object2attach.CData,AxH.CLim)), TName);
        BreastIm = imread(TName);
        delete(TName);
        [sxb,syb]=size(BreastIm);
        if~isfield(parentfigure.UserData,'CompiledHeaderData')
            temp = inputdlg('Insert # acq per step');
            pixels_per_mm = 1/str2double(temp{1});
        else
            pixels_per_mm = 1/parentfigure.UserData.CompiledHeaderData.LoopDelta(1);
        end
        InterpolatedBreasIm=imresize(BreastIm, [sxb/pixels_per_mm*PixelResolution, syb/pixels_per_mm*PixelResolution],'Method','nearest');
        [sx2,sy2]=size(InterpolatedBreasIm);
        %select reference point in image breast (interp2)
        if isempty(TrimCoord)
            [XC2,YC2]=GetCenter(InterpolatedBreasIm);
        else
            YC2 = TrimCoord/pixels_per_mm*PixelResolution;
            XC2 = 1/pixels_per_mm*PixelResolution;
        end
        
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
        %rgb = imresize(rgb,[sxb syb],'Method','nearest');
        FigureName = ['Overlapped - ' parentfigure.Name];
        FH = CreateOrFindFig(FigureName);
        imagesc(rgb);
        ah = gca;
        ah.XTickLabel=cellstr(num2str(cellfun(@str2num,ah.XTickLabel,'UniformOutput',1)/PixelResolution));
        ah.YTickLabel=cellstr(num2str(cellfun(@str2num,ah.YTickLabel,'UniformOutput',1)/PixelResolution));
        SetAxesAppeareance(gca);
        FH.UserData.FigCategory = 'Overlapped';
        FH.UserData.ScaleFactor = PixelResolution;
        FH.UserData.OverlapInfo.indexes = indexes;
        FH.UserData.OverlapInfo.map = map;
        FH.UserData.OverlapInfo.pixels_per_mm = pixels_per_mm;
        FH.UserData.OverlapInfo.PixelResolution = PixelResolution;
        parentfigure.UserData.OverlalpInfo = FH.UserData.OverlapInfo;
        AddToFigureListStruct(FH,MFH,'data',parentfigure.UserData.DataFilePath);
    end
    function TrimmCoord=ShowTrimmerPoint(~,~)
        TrimmCoord = [];
        [Path,FileName,~]=fileparts(parentfigure.UserData.DataFilePath);
        InfoFilePath = fullfile(Path,[FileName,'_info.txt']);
        if ~isfile(InfoFilePath)
            [FileName,Path,FilterIndex]=uigetfilecustom('*.txt;','Select info file');
            if FilterIndex == 0, return, end
            InfoFilePath = [Path,FileName];
        end
        InfoScan=readtable(InfoFilePath);
        Data = object2attach.CData;
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
    function CreateLinkDataFigure(src,~)
        fh = ancestor(src,'figure');
        if ~isfield(fh.UserData,'OverlapInfo')
            errordlg('Choose an image with overalp info','Error');
            return
        end
        [FH,CH,CBH]=CreateLinkDataFigGen(MFH);
        CreatePushButton(FH,'Units','Normalized','Position',[0.85 0 0.10 0.08],'String','Link&Run','Callback',{@OverlapPictureToAll,CBH,fh});
        AddToFigureListStruct(FH,MFH,'side');
    end
    function OverlapPictureToAll(src,~,CheckBoxHandle,ActualFig)
        StartWait(ancestor(src,'figure'));
        indexes = ActualFig.UserData.OverlapInfo.indexes;
        map = ActualFig.UserData.OverlapInfo.map;
        pixels_per_mm = ActualFig.UserData.OverlapInfo.pixels_per_mm;
        PixelResolution = ActualFig.UserData.OverlapInfo.PixelResolution;
        
        actualfhlist = MFH.UserData.AllDataFigs(~contains(MFH.UserData.ListFigures.String,'Select filters'));
        FHList=actualfhlist(logical([CheckBoxHandle.Value]));
        for ifigs=1:numel(FHList)
            FigureParent = FHList(ifigs);
            FigureParent = copyfig(FigureParent);
            FigureParent.Visible = 'on';
            delete(findobj(FigureParent,'type','uicontrol'));
            StartWait(FigureParent);
            AxH = findobj(FigureParent,'type','axes');
            for iaxh = 1:numel(AxH)
                ImH=findobj(AxH(iaxh),'type','image');
                TName = [tempname,'.tiff'];
                imwrite(uint8((255)*mat2gray(ImH.CData,AxH(iaxh).CLim)), TName);
                BreastIm = imread(TName);
                delete(TName);
                delete(ImH);
                [sxb,syb]=size(BreastIm);
                InterpolatedBreasIm=imresize(BreastIm, [sxb/pixels_per_mm*PixelResolution, syb/pixels_per_mm*PixelResolution],'Method','nearest');
                rgb=ind2rgb(InterpolatedBreasIm,map);
                rgb=padarray(rgb,[abs(size(indexes,1)-size(rgb,1)),0,0],0,'post');
                rgb([indexes,indexes,indexes])=0; %set the rgb image to 0 in the selected values
                rgb(indexes)=255;
                imagesc(AxH(iaxh),rgb);
                SetAxesAppeareance(AxH(iaxh));
            end
            FigureParent.UserData.FigCategory = 'Overlapped';
            FigureParent.Name = ['Overlapped - ' FigureParent.Name];
            AddToFigureListStruct(FigureParent,MFH,'data',FigureParent.UserData.DataFilePath);
            StopWait(FigureParent);
        end
        StopWait(ancestor(src,'figure'));
    end
end