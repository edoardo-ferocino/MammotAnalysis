function AddGetDataProfile(parentfigure,object2attach,MFH)
[~,name,~] = fileparts(MFH.UserData.DispDatFilePath.String);
FigureName = ['Profile Curve - ' name];
MenuName = 'Get profile';
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
uimenu(cmh,'Label',MenuName,'CallBack',{@SelectProfileOnGraph,parentfigure});

    function SelectProfileOnGraph(src,~,figh)
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
        dch.DisplayStyle = 'window';ObjMenu = src;
        dch.UpdateFcn = {@ProfileOnGraph,ObjMenu};
    end
    function output_txt=ProfileOnGraph(src,~,~)
        pos = src.Position; Xpos = pos(1); Ypos = pos(2);
        FH=CreateOrFindFig(FigureName,false,'NumberTitle','off');
        realhandle = findobj(ancestor(src,'axes'),'type','image');
        Data = realhandle.CData;
        [numy,numx]=size(Data);
        output_txt = {['X: ',num2str(round(Xpos))],...
            ['Y: ',num2str(round(Ypos))],['Z: ',num2str(Data(Ypos,Xpos))]};
        if strcmpi(MFH.UserData.ProfileOrientation,'vertical')
            plot(1:numy,Data(:,Xpos));
        else
            plot(1:numx,Data(Ypos,:));
        end
        figure(ancestor(src,'figure'));
        movegui(FH,'southwest')
        AddToFigureListStruct(FH,MFH,'side');
        MinimizeFFS(ancestor(src,'figure'));
    end
end