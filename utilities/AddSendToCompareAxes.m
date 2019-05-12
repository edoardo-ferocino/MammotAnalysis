function AddSendToCompareAxes(parentfigure,object2attach,MFH)
MenuName = 'Send to axes';
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
mmh = uimenu(cmh,'Label',MenuName);
pos_string = {'Top left' 'Top right' 'Bottom left' 'Bottom right'};
for is = 1:numel(pos_string)
    uimenu(mmh,'Label',pos_string{is},'CallBack',{@SendToCompareAxes,MFH.UserData.CompareAxes(is),object2attach});
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
    end
end