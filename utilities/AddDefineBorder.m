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
        ShapeHandle.Color = 'red';
        ShapeHandle.StripeColor = 'yellow';
        uimenu(ShapeHandle.UIContextMenu,'Text',['Copy DefineBorder ROI ',num2str(ShapeHandle.UserData.ID)],'CallBack',{@CopyRoi,ShapeHandle});
        submH = uimenu(ShapeHandle.UIContextMenu,'Text',['Apply DefineBorder ROI ',num2str(ShapeHandle.UserData.ID)]);
        uimenu(submH,'Text','Delete external','CallBack',{@CreateLinkDataFigure,ShapeHandle,'external'});
        uimenu(submH,'Text','Delete internal','CallBack',{@CreateLinkDataFigure,ShapeHandle,'internal'});
        draw(ShapeHandle)
    end
    function CreateLinkDataFigure(~,~,ShapeHandle,DeleteType)
        FH = CreateOrFindFig('Link Figures','NumberTitle','off','Toolbar','None','MenuBar','none');
        clf(FH);
        FH.UserData.FigCategory = 'LinkFigures';
        actualnameslist = MFH.UserData.ListFigures.String(~contains(MFH.UserData.ListFigures.String,'Select filters'));
        numfig = numel(actualnameslist);
        for ifigs = 1:numfig
            CH(ifigs) = CreateContainer(FH,'BorderType','none','Units','Normalized','Position',[0 (1/numfig)*(ifigs-1) 1 1/numfig]);%,'BorderType','none');
            CreateEdit(CH(ifigs),'String',actualnameslist{ifigs},'HorizontalAlignment','Left',...
                'Units','Normalized','OuterPosition',[0 0 0.7 1]);
            CBH(ifigs) = CreateCheckBox(CH(ifigs),'String','Link','Units','Normalized','Position',[0.7 0 0.1 1]);
        end
        %         EH=CreateEdit(FH,'String','Linked Name(Type)','HorizontalAlignment','Left',...
        %                 'Units','Normalized','Position',[0.80 0.08 0.20 0.08]);
        CreatePushButton(FH,'Units','Normalized','Position',[0.90 0 0.10 0.08],'String','Link&Run','Callback',{@ApplyRoi,ShapeHandle,DeleteType,CBH});
        AddToFigureListStruct(FH,MFH,'side');
    end
    function ApplyRoi(src,~,ShapeHandle,DeleteType,CheckBoxHandle)
        StartWait(ancestor(src,'figure'));
        actualfhlist = MFH.UserData.AllDataFigs(~contains(MFH.UserData.ListFigures.String,'Select filters'));
        FHList=actualfhlist(logical([CheckBoxHandle.Value]));
        for ifigs=1:numel(FHList)
            FigureParent = FHList(ifigs);
            StartWait(FigureParent);
            FH = copyobj(FigureParent,groot,'legacy');
            AxH = findobj(FH,'type','axes');
            for iaxh = 1:numel(AxH)
                ImH = findobj(AxH(iaxh),'type','image');
                if strcmpi(DeleteType,'external')
                    ImH.CData = ImH.CData .*ShapeHandle.createMask;
                    if(isfield(FH.UserData,'ActualDatData'))
                        Size=size(FH.UserData.ActualDatData);
                        FH.UserData.ActualDatData = FH.UserData.ActualDatData.*...
                            padarray(repmat(ShapeHandle.createMask,[1 1 Size(3) Size(4)]),FH.UserData.Numel2Pad,'post');
                    end
                else
                    ImH.CData = ImH.CData .*~ShapeHandle.createMask;
                    if(isfield(FH.UserData,'ActualDatData'))
                        Size=size(FH.UserData.ActualDatData);
                        FH.UserData.ActualDatData = FH.UserData.ActualDatData.*...
                            padarray(~repmat(ShapeHandle.createMask,[1 1 Size(3) Size(4)]),FH.UserData.Numel2Pad,'post');
                    end
                end
                PercVal = GetPercentile(ImH.CData,PercFract);
                ImH.Parent.CLim = [0 PercVal];
            end
            newName = FH.Name;
            while ~isempty(findobj('name',newName,'type','figure'))
                newName = [newName '-Cropped'];  %#ok<AGROW>
            end
            FH.Name = newName;
            shapeh = findobj(FH,'type','images.roi');
            delete(shapeh);
            AddToFigureListStruct(FH,MFH,'data',FH.UserData.DataFilePath)
            movegui(FH,'center')
            StopWait(FigureParent);
            StopWait(FH);
        end
        StopWait(ancestor(src,'figure'));
        msh = msgbox({'Roi applied' 'The new figure will be listed in the list box'},'Success','help');
        movegui(msh,'center');
        waitfor(msh);
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