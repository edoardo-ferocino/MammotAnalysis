function AddInfoEntry(parentfigure,object2attach,figentry,infodata,MFH)
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
infomenuh = findobj(cmh,'Text','Info Data');
if isempty(infomenuh)
   infomenuh = uimenu(cmh,'Text','Info Data');
end
uimenu(infomenuh,'Text',figentry.Name,'Callback',{@GetInfoData,infodata});

    function GetInfoData(src,~,infodata)
        if (isfield(src.UserData,'FigRoiHandle'))
            FH = src.UserData.FigRoiHandle;
            FH.UserData.RoiObjHandle = src;
            figure(FH)
        else
            FH=figure('NumberTitle','off','Name',['Info: ' figentry.Name],'ToolBar','none');
            src.UserData.FigRoiHandle = FH;
            if ~isfield(MFH.UserData,'SideFigs')
                MFH.UserData.SideFigs = FH;
            else
                MFH.UserData.SideFigs(end+1) = FH;
            end
        end
        if isrow(infodata.Name), infodata.Name = infodata.Name'; end
        if isrow(infodata.Value), infodata.Value = infodata.Value'; end
        tbh = uitable(FH,'ColumnName',{figentry.Name},'RowName',infodata.Name,'Data',infodata.Value,'ColumnFormat',{'char'});
        tbh.Position([3 4]) = tbh.Extent([3 4]);
        FH.Position = tbh.Position + [0 0 70 40];
        movegui(FH,'southeast')
    end

end