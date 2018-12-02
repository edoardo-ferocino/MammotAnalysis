function AddGetDataProfile(parentfigure,object2attach)
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
mmh = uimenu(cmh,'Label','Get profile','CallBack',{@SelectProfileOnGraph,parentfigure});
%submh = uimenu(mmh,'Label',Shapes{is},'CallBack',{@SelectRoiOnGraph,Shapes{is}});


    function SelectProfileOnGraph(src,event,figh)
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
        dch.UpdateFcn = @ProfileOnGraph;
    end
    function output_txt=ProfileOnGraph(src,event)
        pos = src.Position; Xpos = pos(1); Ypos = pos(2);
        
        if (isfield(src.UserData,'FigProfileHandle'))
            FH = src.UserData.FigProfileHandle;
            FH.UserData.FigProfileHandle = src;
            figure(FH);
        else
            FH=figure('NumberTitle','off','Name','Profile');
            src.UserData.FigProfileHandle = FH;
        end
        nchild = numel(src.Parent.Children);
        for inc = 1:nchild
            if strcmpi(src.Parent.Children(inc).Type,'image')
                realhandle = src.Parent.Children(inc);
            end
        end
        Data = realhandle.CData;
        [numy,numx]=size(Data);
        Xv = realhandle.XData; Yv = realhandle.YData;
        if (numel(Xv)==2)
            Xv = linspace(Xv(1),Xv(2),numx);
            Yv = linspace(Yv(1),Yv(2),numy);
        end
        [~,MinIndxX]=min(abs(Xv-Xpos));[~,MinIndxY]=min(abs(Yv-Ypos));
        DataXpos = MinIndxX;DataYpos = MinIndxY;
        output_txt = {['X: ',num2str(round(Xpos))],...
            ['Y: ',num2str(round(Ypos))],['Z: ',num2str(Data(DataYpos,DataXpos))]};
        plot(Xv,Data(DataYpos,:));
        figure(ancestor(src,'figure'));
        MinimizeFFS(ancestor(src,'figure'));
    end
end