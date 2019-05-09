function AddPicture(parentfigure,object2attach,MFH)
return
CallBackHandle = @OverlapPicture;
MenuName = 'Overlap Picture';
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
uimenu(cmh,'Text',MenuName,'CallBack',{CallBackHandle,parentfigure});

    function OverlapPicture(~,~,shape,object2attach)
        [FilePath,FileName,Ext] = fileparts(MFH.UserData.DatFilePath);
        %FullPathPicture = [fullfile(FilePath,'\Pictures',FileName) '.png'];
        FullPathPicture='C:\Users\Mammot\Desktop\RR0200.png';
        if isfile(FullPathPicture)
            ax = gca;
            I = getimage;
            [Y,X] = size(I);
            [Picture,map,alpha] = imread(FullPathPicture);
            Picture = imresize(Picture, [Y X]);
            h = imshow(Picture);
            set(h, 'AlphaData', 0.7);
            axis on
        else
            msgbox('No corresponding picture available', 'Error','error');
        end
        %uimenu(h,'Text','Remove Picture','CallBack',{@RemovePicture,h});
    end

    function RemovePicture(~,~,h)
        delete(h)
    end
end