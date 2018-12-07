function AddGetDataProfile(parentfigure,object2attach,MFH)
global MainFigureName;
MainFigureName = MFH.UserData.Name;
[~,name,~] = fileparts(MFH.UserData.DispDatFilePath.String);
global FigureName;
FigureName = ['Profile Curve - ' name];
global FigureNameHandle;
FigureNameHandle = 'ProfileCurveHandle';
global CallBackHandle;
CallBackHandle = @SelectProfileOnGraph;
global MenuName;
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
    function output_txt=ProfileOnGraph(src,~,ObjMenu)
        pos = src.Position; Xpos = pos(1); Ypos = pos(2);
        
        if (isfield(ObjMenu.UserData,FigureNameHandle))
            FH = ObjMenu.UserData.(FigureNameHandle);
            FH.UserData.(FigureNameHandle) = ObjMenu.UserData.(FigureNameHandle);
            figure(FH);
        else
            FH=figure('NumberTitle','off','Name',FigureName);
            ObjMenu.UserData.(FigureNameHandle) = FH;
            if ~isfield(MFH.UserData,'SideFigs')
                MFH.UserData.SideFigs = FH;
            else
                MFH.UserData.SideFigs(end+1) = FH;
            end
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
        ph = plot(Xv,Data(DataYpos,:));
        if MFH.UserData.isXDirReverse
            ph.Parent.XDir = 'reverse';
        end
        figure(ancestor(src,'figure'));
        movegui(FH,'southwest')
        MinimizeFFS(ancestor(src,'figure'));
    end
end