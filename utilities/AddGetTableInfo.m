function AddGetTableInfo(parentfigure,object2attach,Filters,rows,AllData)
CallBackHandle = @PickInfo;
MenuName = 'Pick Info';
PickInfoNames = {Filters.Name};
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
menuh = uimenu(cmh,'Text',MenuName);

for info = 1:numel(PickInfoNames)
   submh = uimenu(menuh,'Text',PickInfoNames{info},'CallBack',{CallBackHandle,parentfigure,menuh});
   submh.UserData.submh = submh;
end


    function PickInfo(src,~,figh,menuh)
        if strcmpi(src.Checked,'off')
            src.Checked = 'on';
            src.UserData.originalprops = datacursormode(figh);
        else
            src.Checked = 'off';
        end
        dch = datacursormode(figh);
        if strcmpi(src.Checked,'off')
            dch.DisplayStyle = 'datatip';
            dch.UpdateFcn = [];
            return
        end
        
        datacursormode on
        dch.DisplayStyle = 'window'; 
        ObjMenu = menuh.Children(strcmpi({menuh.Children.Checked},'on'));
        dch.UpdateFcn = {@PickInfoOnGraph,ObjMenu};
    end
    function output_txt=PickInfoOnGraph(src,~,ObjMenu)
        pos = src.Position; Xpos = pos(1); Ypos = pos(2);
        realhandle = findobj(ancestor(src,'axes'),'type','image');
        Xrows = AllData.X == Xpos-1;
        Yrows = AllData.Y == Ypos-1;
        newrows = all([rows Xrows Yrows],2);
        for iobj = 1:numel(ObjMenu)
            newval = mean(AllData(newrows,ObjMenu(iobj).UserData.submh.Text).Variables);
            string2plot{iobj} = [ObjMenu(iobj).UserData.submh.Text, ': ',num2str(newval)];
        end
        Zval = realhandle.CData(Ypos,Xpos);
        output_txt = {['X: ',num2str(round(Xpos))],...
            ['Y: ',num2str(round(Ypos))],...
            ['Z: ',num2str(Zval)],...
            string2plot{:}};%[ObjMenu.UserData.submh.Label, ': ',num2str(newval)]};
    end
end