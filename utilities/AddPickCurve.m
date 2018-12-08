function AddPickCurve(parentfigure,object2attach,Data,MFH)
[~,name,~] = fileparts(MFH.UserData.DispDatFilePath.String);
global FigureName;
FigureName = ['Pick Curve - ' name];
global FigureNameHandle;
FigureNameHandle = 'PickCurveHandle';
global CallBackHandle;
CallBackHandle = @PickCurve;
global MenuName;
MenuName = 'Pick Curve';
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
uimenu(cmh,'Text',MenuName,'CallBack',{CallBackHandle,parentfigure});


    function PickCurve(src,~,figh)
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
        dch.UpdateFcn = {@PickCurveOnGraph,ObjMenu};
    end
    function output_txt=PickCurveOnGraph(src,~,ObjMenu)
        AncestorFigure = ancestor(src,'figure');
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
        movegui(FH,'southwest')

        %realhandle = findobj(ancestor(src,'axes'),'type','image');
        [~,~,numbin]=size(Data);
        output_txt = {['X: ',num2str(round(Xpos))],...
            ['Y: ',num2str(round(Ypos))],['Z: ',num2str(sum(Data(Ypos,Xpos,:))./MFH.UserData.CompiledHeaderData.McaTime)]};
        semilogy(1:numbin,squeeze(Data(Ypos,Xpos,:)));
        ylim([10 max(Data(:))]);
        figure(AncestorFigure);
        MinimizeFFS(AncestorFigure);
    end
end