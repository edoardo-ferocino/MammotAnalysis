function AddSaveNewFile(parentfigure,object2attach,~)
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
uimenu(cmh,'Text','Save data to new file','Callback',{@SaveToNewFile});


    function SaveToNewFile(~,~)
        StartWait(gcf);
        [~,FileName,~] = fileparts(parentfigure.UserData.DatFilePath);
        [FileName,PathName,FilterIdx] = uiputfilecustom([FileName '.DAT'],'Select destination folder');
        if FilterIdx == 0, return; end
        Data = parentfigure.UserData.ActualDatData;
        [NumY,NumX,NumChan,~]=size(Data);
        Data=flip(Data,2);
        H = parentfigure.UserData.HeaderData;
        SUBH = parentfigure.UserData.SubHeaderData;
        if NumChan == 1
           SUBH = permute(SUBH,[1 2 4 3]);
        end
        Datatype = parentfigure.UserData.DataType;
        
        fid_out = fopen(fullfile(PathName,FileName), 'wb');
        fwrite(fid_out, H, 'uint8');
        for iy = 1:NumY
            for ix = 1:NumX
                for ich = 1:NumChan
                    fwrite(fid_out, SUBH(iy,ix,ich,:), 'uint8');
                    curve=squeeze(Data(iy,ix,ich,:));
                    fwrite(fid_out, curve, Datatype);
                end
            end
        end
        fclose(fid_out);
        StopWait(gcf);
        msgbox('File written','Success','help');
    end
end