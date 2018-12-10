function AddSendToCompareAxes(subH,parentfigure,MFH)
MenuName = 'Send to axes';
object2attach = findobj(parentfigure,'Type','image');
for obj = 1:numel(object2attach)
    if isempty(object2attach(obj).UIContextMenu)
        cmh = uicontextmenu(parentfigure);
        object2attach(obj).UIContextMenu = cmh;
    else
        cmh = object2attach(obj).UIContextMenu;
    end
    mmh = uimenu(cmh,'Label',MenuName);
    pos_string = {'Top left' 'Top right' 'Bottom left' 'Bottom right'};
    for is = 1:numel(subH)
        uimenu(mmh,'Label',pos_string{is},'CallBack',{@SendToCompareAxes,subH(is),object2attach(obj)});
    end
    
end
    function SendToCompareAxes(~,~,subH,obj)
        copied_obj = copyobj(obj,subH,'legacy');
        FH = ancestor(obj,'figure'); OrigFigName = FH.Name;
        AXH = ancestor(obj,'axes'); OrigTitle = AXH.Title.String;
        axes(subH); subH.YDir = 'reverse';
        subH.CLim = AXH.CLim;
        colormap pink, shading interp, axis image;
        th = title({OrigFigName,OrigTitle},'Interpreter','none');
        th.FontSize = 7;
        AddSelectRoi(MFH,copied_obj,MFH)
        %copiedobj.UIContextMenu = obj.UIContextMenu;
    end
end