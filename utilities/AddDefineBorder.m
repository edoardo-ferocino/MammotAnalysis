function AddDefineBorder(parentfigure,object2attach,MFH)
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
        AxH = ancestor(object2attach,'axes');
        ShapeHandle = images.roi.(shape)(AxH);
        ShapeHandle.UserData.Type = 'DefineBorder';
        if isempty(RoiObjs)
            ShapeHandle.UserData.ID = 1;
            MFH.UserData.Roi.(ShapeHandle.UserData.Type).ID = 1;
        else
            ShapeHandle.UserData.ID = numel(RoiObjs)+1;
            MFH.UserData.Roi.(ShapeHandle.UserData.Type).ID = ...
                MFH.UserData.Roi.(ShapeHandle.UserData.Type).ID+1;
        end
        ShapeHandle.FaceAlpha = 0;
        ColIDX = rem(MFH.UserData.Roi.(ShapeHandle.UserData.Type).ID,numel(ColorList))+1;
        ShapeHandle.Color = ColorList{ColIDX};
        ShapeHandle.StripeColor = 'yellow';
        uimenu(ShapeHandle.UIContextMenu,'Text',['Copy DefineBorder ROI ',num2str(ShapeHandle.UserData.ID)],'CallBack',{@CopyRoi,ShapeHandle});
        submH = uimenu(ShapeHandle.UIContextMenu,'Text',['Apply DefineBorder ROI ',num2str(ShapeHandle.UserData.ID)]);
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
                    tshapeh = shapeh(ish);
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
        AddToFigureListStruct(FH,MFH,'data',FH.UserData.FHDataFilePath)
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
        waitfor(msh);
        answer = questdlg('Use the cropped data for analysis?','Cropped data','Yes','No','No');
        if strcmpi(answer,'yes')
           msh = msgbox('Please run again the analysis','Success','help');
           movegui(msh,'center');
           waitfor(msh);
           MFH.UserData.DataMask = tshapeh.createMask; 
           MFH.UserData.DataMaskDelType = Deletetype;
           MFH.UserData.DataMaskHandle = tshapeh;
           MFH.UserData.ApplyDataMask = true;
        end
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
                umh = uimenu(cntxh,'Text',['Paste ',num2str(roiobj.UserData.ID),' roi'],'CallBack',{@PasteRoi,obj2attach(in)});
                MFH.UserData.TempMenuH(icntxh) = umh;
                icntxh = icntxh+1;
            end
        end
        msgbox(['Copied ROI ',num2str(roiobj.UserData.ID),' object'],'Success','help');
    end
    function PasteRoi(~,~,obj2attach)
        RoiObj = copyobj(MFH.UserData.CopiedRoi,ancestor(obj2attach,'axes'),'legacy');
        RoiObj.UserData.ID = MFH.UserData.(RoiObj.UserData.Type).ID+1;
        MFH.UserData.(RoiObj.UserData.Type).ID=MFH.UserData.(RoiObj.UserData.Type).ID+1;
        RoiObj.UIContextMenu.Children(...
            contains(lower({RoiObj.UIContextMenu.Children.Text}),'copy')).MenuSelectedFcn{2} = RoiObj;
        RoiObj.UIContextMenu.Children(...
            contains(lower({RoiObj.UIContextMenu.Children.Text}),'delete')).MenuSelectedFcn = {@DeleteRoi,RoiObj};
        RoiObj.Color = 'red';
        RoiObj.StripeColor = 'yellow';
        for icntxh = 1:numel(MFH.UserData.TempMenuH)
            MFH.UserData.TempMenuH(icntxh).delete;
            delete(MFH.UserData.TempMenuH(icntxh));
        end
        MFH.UserData = rmfield(MFH.UserData,'TempMenuH');
        MFH.UserData = rmfield(MFH.UserData,'CopiedRoi');
    end
end