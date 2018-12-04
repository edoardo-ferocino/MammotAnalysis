function AddInfoEntry(ctxmh,figentry,infodata)
uimenu(ctxmh,'Label',figentry.Name,'Callback',{@GetInfoData,infodata});
    function GetInfoData(~,~,infodata)
        FH = figure(468);
        FH.ToolBar = 'none'; FH.MenuBar = 'none'; FH.Name = figentry.Name;
        FH.NumberTitle = 'off';
        if isrow(infodata.Name), infodata.Name = infodata.Name'; end
        if isrow(infodata.Value), infodata.Value = infodata.Value'; end
        tbh = uitable(FH,'RowName',infodata.Name,'Data',infodata.Value,'ColumnName','Val');
        tbh.Position([3 4]) = tbh.Extent([3 4]);
        FH.Position = tbh.Position + [0 0 70 40];
        movegui(FH,'southeast')
    end

end