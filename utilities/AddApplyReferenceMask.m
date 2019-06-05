function AddApplyReferenceMask(parentfigure,object2attach,MFH)
PercFract = 95;
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
mmh = uimenu(cmh,'Text','Reference Mask');
uimenu(mmh,'Text','Apply Reference Mask','Callback',{@ApplyReferenceMask});
uimenu(mmh,'Text','Remove Reference Mask','Callback',{@RemoveReferenceMask});
    function ApplyReferenceMask(~,~)
        if ~isfield(parentfigure.UserData,'TotalReferenceMask')
            errordlg('no reference mask'); return
        end
        object2attach.CData = object2attach.CData .* parentfigure.UserData.TotalReferenceMask;
        %PercVal = GetPercentile(AxH.CData,PercFract);
    end
    function RemoveReferenceMask(~,~)
        if ~isfield(parentfigure.UserData,'TotalReferenceMask')
            errordlg('no reference mask'); return
        end
        AxH=ancestor(object2attach,'axes');
        object2attach.CData = object2attach.UserData.OriginalCData;
        AxH.CLim = AxH.UserData.OriginalCLims;
        %PercVal = GetPercentile(AxH.CData,PercFract);
    end
end