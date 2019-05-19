function AddInfoEntry(parentfigure,object2attach,figentry,MFH)
if ~isfield(figentry.UserData,'InfoData'),return,end
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
infodata = figentry.UserData.InfoData;
uimenu(infomenuh,'Text',figentry.Name,'Callback',{@GetInfoData,infodata});

    function GetInfoData(~,~,infodata)
        FH=CreateOrFindFig(['Info: ' figentry.Name],'NumberTitle','off','MenuBar','none','ToolBar','none');
        if isstring(infodata.Name), infodata.Name = {infodata.Name{:}};  end
        if isstring(infodata.Value), infodata.Value = {infodata.Value{:}};  end
        if isrow(infodata.Name), infodata.Name = infodata.Name'; end
        if isrow(infodata.Value), infodata.Value = infodata.Value'; end
        tbh = uitable(FH,'ColumnName',{figentry.Name},'RowName',infodata.Name,'Data',infodata.Value,'ColumnFormat',{'char'});
        tbh.Position([3 4]) = tbh.Extent([3 4]);
        FH.Position = tbh.Position + [0 0 70 40];
        FH.UserData.FigCategory = 'Info';
        movegui(FH,'southeast')
        AddToFigureListStruct(FH,MFH,'side');
    end

end