function AddGetTableInfo(parentfigure,object2attach,MFH,Filters,rows,UnstackedRealPage,AllData)
global CallBackHandle;
CallBackHandle = @PickInfo;
global MenuName;
MenuName = 'Pick Info';
PickInfoNames = {Filters.Name};
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
umh = uimenu(cmh,'Label',MenuName);

for info = 1:numel(PickInfoNames)
   submh = uimenu(umh,'Label',PickInfoNames{info},'CallBack',{CallBackHandle,parentfigure});
   submh.UserData.submh = submh;
end


    function PickInfo(src,~,figh)
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
        dch.DisplayStyle = 'window'; ObjMenu = src;
        dch.UpdateFcn = {@PickInfoOnGraph,ObjMenu};
    end
    function output_txt=PickInfoOnGraph(src,~,ObjMenu)
        pos = src.Position; Xpos = pos(1); Ypos = pos(2);
        nchild = numel(src.Parent.Children);
        for inc = 1:nchild
            if strcmpi(src.Parent.Children(inc).Type,'image')
                realhandle = src.Parent.Children(inc);
            end
        end
        [numy,numx]=size(UnstackedRealPage.Variables);
        Xv = realhandle.XData; Yv = realhandle.YData;
        if (numel(Xv)==2)
            Xv = linspace(Xv(1),Xv(2),numx);
            Yv = linspace(Yv(1),Yv(2),numy);
        end
        [~,MinIndxX]=min(abs(Xv-Xpos));[~,MinIndxY]=min(abs(Yv-Ypos));
        DataXpos = MinIndxX;DataYpos = MinIndxY;
%         TableInfoVal = AllData(rows,ObjMenu.UserData.submh.Label);
        Xrows = AllData.X == Xpos;
        Yrows = AllData.Y == Ypos;
        newrows = all([rows Xrows Yrows],2);
        newval = AllData(newrows,ObjMenu.UserData.submh.Label).Variables;
        Zval = UnstackedRealPage(Ypos+1,Xpos+1).Variables;
        output_txt = {['X: ',num2str(round(Xpos))],...
            ['Y: ',num2str(round(Ypos))],...
            ['Z: ',num2str(Zval)],...
            [ObjMenu.UserData.submh.Label, ': ',num2str(newval)]};
    end
end