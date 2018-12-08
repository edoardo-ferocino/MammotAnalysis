function AddDefineBorder(parentfigure,object2attach,MFH)
global PercFract
PercFract = 95;
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
mmh = uimenu(cmh,'Text','Define border');
Shapes = {'Rectangle' 'Freehand'};
for is = 1:numel(Shapes)
    uimenu(mmh,'Text',Shapes{is},'CallBack',{@DefineBorder,Shapes{is},object2attach});
end

    function DefineBorder(~,~,shape,object2attach)
        RoiObjs = findobj(object2attach,'Type','images.roi');
        ColorList ={'red'};
        AxH = object2attach.Parent;
        ShapeHandle = images.roi.(shape)(AxH);
        ShapeHandle.UserData.Type = 'DefineBorder';
        if isempty(RoiObjs)
            ShapeHandle.UserData.ID = 1;
        else
            ShapeHandle.UserData.ID = numel(RoiObjs)+1;
        end
        ShapeHandle.FaceAlpha = 0;
        ColIDX = rem(ShapeHandle.UserData.ID,numel(ColorList))+1;
        ShapeHandle.Color = ColorList{ColIDX};
        ShapeHandle.StripeColor = 'yellow';
        uimenu(ShapeHandle.UIContextMenu,'Text','Copy DefineBorder ROI','CallBack',{@CopyRoi,ShapeHandle});
        submH = uimenu(ShapeHandle.UIContextMenu,'Text','Apply DefineBorder ROI');
        uimenu(submH,'Text','Delete external','CallBack',{@ApplyRoi,ShapeHandle,'external'});
        uimenu(submH,'Text','Delete internal','CallBack',{@ApplyRoi,ShapeHandle,'internal'});
        draw(ShapeHandle)
    end
    function ApplyRoi(src,~,ShapeHandle,Deletetype)
        FigureParent = ancestor(src,'figure');
        StartWait(FigureParent);
        FH = copyobj(FigureParent,groot,'legacy');
        AxH = findobj(FH.Children,'type','axes');
        for iaxh = 1:numel(AxH)
            ImH = findobj(AxH(iaxh).Children,'type','image');
            shapeh = findobj(ShapeHandle.Parent.Children,'type','images.roi');
            for ish = 1:numel(shapeh)
                if strcmpi(shapeh(ish).UserData.Type,'DefineBorder')
                    if strcmpi(Deletetype,'external')
                        ImH.CData = ImH.CData .*shapeh(ish).createMask;
                    else
                        ImH.CData = ImH.CData .*~shapeh(ish).createMask;
                    end
                    PercVal = GetPercentile(ImH.CData,PercFract);
                    ImH.Parent.CLim = [0 PercVal];
                end
            end
        end
        newName = FH.Name;
        while ~isempty(findobj('name',newName,'type','figure'))
           newName = [newName '-Cropped'];  %#ok<AGROW>
        end
        FH.Name = newName;
        shapeh = findobj(FH,'type','images.roi');
        delete(shapeh);
        for ifigs = 1:numel(FH)
            FH(ifigs).Visible = 'off';
            FH(ifigs).CloseRequestFcn = {@SetFigureInvisible,FH(ifigs)};
            AddElementToList(MFH.UserData.ListFigures,FH(ifigs));
        end
        AddToFigureListStruct(FH,MFH,'data')
        movegui(FH,'center')
        StopWait(FigureParent);
        StopWait(FH);
        imh = findobj(FH,'type','image');
        for ih = 1:numel(imh)
            if isfield(MFH.UserData,'rows')
                AddGetTableInfo(FH,imh(ih),MFH.UserData.Filters,MFH.UserData.rows,MFH.UserData.AllData)
            end
            AddSelectRoi(FH,imh(ih),MFH);
            AddDefineBorder(FH,imh(ih),MFH);
        end
        if isfield(FH.UserData,'InfoData')
            AddInfoEntry(MFH,MFH.UserData.ListFigures,FH,FH.UserData.InfoData,MFH);
        end
        msh = msgbox({'Roi applied' 'The new figure will be listed in the list box'},'Success','help');
        movegui(msh,'center');
    end
    function CopyRoi(~,~,roiobj)
        MFH.UserData.CopiedRoi = roiobj;
        icntxh = 1;
        for ifigs = 1:numel(MFH.UserData.AllDataFigs)
            obj2attach = findobj(MFH.UserData.AllDataFigs(ifigs),'Type','image');
            for in = 1:numel(obj2attach)
                if isempty(obj2attach(in).UIContextMenu)
                    cntxh = uicontextmenu(MFH.UserData.AllDataFigs(ifigs));
                    obj2attach(in).UIContextMenu = cntxh;
                else
                    cntxh = obj2attach(in).UIContextMenu;
                end
                umh = uimenu(cntxh,'Text','Paste roi','CallBack',{@PasteRoi,obj2attach(in)});
                MFH.UserData.TempMenuH(icntxh) = umh;
                icntxh = icntxh+1;
            end
        end
        msgbox('Copied ROI object','Success','help');
    end
    function PasteRoi(~,~,obj2attach)
        RoiObj = copyobj(MFH.UserData.CopiedRoi,obj2attach.Parent,'legacy');
        AllImages = findall(MFH.UserData.AllDataFigs,'type','images.roi');
        MaxIDPos = zeros(numel(AllImages),1);
        for iAl = 1:numel(AllImages)
            MaxIDPos(iAl) = AllImages(iAl).UserData.ID;
        end
        MaxVal = max(MaxIDPos);
        RoiObj.UserData.ID = MaxVal+1;
        
        ColorList ={'red'};
        RoiObj.StripeColor = 'yellow';
        RoiObj.UIContextMenu.Children(...
            contains(lower({RoiObj.UIContextMenu.Children.Text}),'copy')).MenuSelectedFcn{2} = RoiObj;
        ColIDX = rem(RoiObj.UserData.ID,numel(ColorList))+1;
        RoiObj.Color = ColorList{ColIDX};
        for icntxh = 1:numel(MFH.UserData.TempMenuH)
            MFH.UserData.TempMenuH(icntxh).delete;
            delete(MFH.UserData.TempMenuH(icntxh));
        end
        MFH.UserData = rmfield(MFH.UserData,'TempMenuH');
        MFH.UserData = rmfield(MFH.UserData,'CopiedRoi');
    end
end