function AddShowGatedCurve(parentfigure,object2attach,MFH)
[~,FileName]=fileparts(parentfigure.UserData.DatFilePath);
GatedCurveFigureName = ['Gated Curve - ' FileName];
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
uimenu(cmh,'Text','Show gated curve','Callback',{@ShowGatedCurve,parentfigure});

    function ShowGatedCurve(src,~,figh)
        if strcmpi(src.Checked,'off')
            src.Checked = 'on';
            src.UserData.originalprops = datacursormode(figh);
        else
            src.Checked = 'off';
        end
        dch = datacursormode(figh);
        dch.removeAllDataCursors;
        if strcmpi(src.Checked,'off')
            dch.DisplayStyle = 'datatip';
            dch.UpdateFcn = [];
            return
        end
        
        datacursormode on
        dch.DisplayStyle = 'window'; ObjMenu = src;
        dch.UpdateFcn = {@ShowGatedPickOnGraph,ObjMenu};
    end
    function output_txt=ShowGatedPickOnGraph(src,~,~)
        pos = src.Position; Xpos = pos(1); Ypos = pos(2);
        %AncestorFigure = ancestor(src,'figure');
        AxH=ancestor(object2attach,'axes');
        GateID=AxH.UserData.ActualGateVal;
        WaveID=AxH.UserData.WaveID;
        Tag = ['GC',parentfigure.Name,'-',WaveID];
        FH=CreateOrFindFig([GatedCurveFigureName,'-Wave:',num2str(MFH.UserData.Wavelengths(WaveID))],'Tag',Tag,'numbertitle','off','MenuBar','none','toolbar','none','units','normalized');
        %cla(findobj(FH,'type','axes'));
        FH.UserData.FigCategory = 'PickGatedCurve';
        GatesWave=parentfigure.UserData.GatesWaves(WaveID);
        lines=semilogy(GatesWave.ReferenceGatesWaveS.VisualTimeInterpAlignedArray,...
            [GatesWave.ReferenceGatesWaveS.InterpIrfCurve./max(GatesWave.ReferenceGatesWaveS.InterpIrfCurve)...
            squeeze(GatesWave.InterpData(Ypos,Xpos,:)./max(GatesWave.InterpData(Ypos,Xpos,:))) ...
            squeeze(GatesWave.Gates(GateID).Curves(Ypos,Xpos,:)./max(GatesWave.InterpData(Ypos,Xpos,:)))]);
        lines(1).Color = 'r';lines(2).Color = 'g';lines(3).Color = 'b';lines(3).LineWidth = 2;
        xlim([0 GatesWave.ReferenceGatesWaveS.VisualTimeInterpAlignedArray(end)]);xlabel ps
        AddToFigureListStruct(FH,MFH,'side');
        output_txt = ['to do'];
        %figure(AncestorFigure);
    end
end