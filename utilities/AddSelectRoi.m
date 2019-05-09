function AddSelectRoi(parentfigure,object2attach,MFH)
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
mmh = uimenu(cmh,'Text','Select roi on graph');
Shapes = {'Rectangle' 'Freehand' 'Circle'};
for is = 1:numel(Shapes)
    uimenu(mmh,'Text',Shapes{is},'CallBack',{@SelectRoiOnGraph,Shapes{is},object2attach});
end


    function SelectRoiOnGraph(~,~,shape,object2attach)
        RoiObjs = findobj(ancestor(object2attach,'axes'),'Type','images.roi');
        ColorList ={'yellow' 'magenta' 'cyan' 'red' 'green' 'blue' 'white' 'black'};
        AxH = object2attach.Parent;
        ShapeHandle = images.roi.(shape)(AxH);
        ShapeHandle.UserData.Type = 'SelectRoi';
        if ~isfield(MFH.UserData,ShapeHandle.UserData.Type)
            ShapeHandle.UserData.ID = 1;
            MFH.UserData.(ShapeHandle.UserData.Type).ID = 1;
        else
            MFH.UserData.(ShapeHandle.UserData.Type).ID = ...
                MFH.UserData.(ShapeHandle.UserData.Type).ID+1;
            ShapeHandle.UserData.ID = MFH.UserData.(ShapeHandle.UserData.Type).ID+1;
        end
        ShapeHandle.FaceAlpha = 0;
        ColIDX = rem(MFH.UserData.(ShapeHandle.UserData.Type).ID,numel(ColorList));
        ShapeHandle.Color = ColorList{ColIDX};
        ShapeHandle.UIContextMenu.Children(...
            contains(lower({ShapeHandle.UIContextMenu.Children.Text}),'delete')).MenuSelectedFcn = {@DeleteRoi,ShapeHandle};
        uimenu(ShapeHandle.UIContextMenu,'Text','Copy ROI','CallBack',{@CopyRoi,ShapeHandle});
        uimenu(ShapeHandle.UIContextMenu,'Text','Apply ROI to all axes','CallBack',{@ApplyRoiToAll,ShapeHandle});
        addlistener(ShapeHandle,'DrawingFinished',@GetData);
        draw(ShapeHandle)
        addlistener(ShapeHandle,'ROIMoved',@GetData);
    end
    function DeleteRoi(~,~,roiobj)
        delete(roiobj)
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

        ColorList ={'yellow' 'magenta' 'cyan' 'red' 'green' 'blue' 'white' 'black'};
        RoiObj.UIContextMenu.Children(...
            contains(lower({RoiObj.UIContextMenu.Children.Text}),'copy')).MenuSelectedFcn{2} = RoiObj;
        RoiObj.UIContextMenu.Children(...
            contains(lower({RoiObj.UIContextMenu.Children.Text}),'delete')).MenuSelectedFcn = {@DeleteRoi,RoiObj};
        ColIDX = rem(RoiObj.UserData.ID,numel(ColorList))+1;
        RoiObj.Color = ColorList{ColIDX};
        GetData(RoiObj,RoiObj);
        addlistener(RoiObj,'ROIMoved',@GetData);
        for icntxh = 1:numel(MFH.UserData.TempMenuH)
            MFH.UserData.TempMenuH(icntxh).delete;
            delete(MFH.UserData.TempMenuH(icntxh));
        end
        MFH.UserData = rmfield(MFH.UserData,'TempMenuH');
        MFH.UserData = rmfield(MFH.UserData,'CopiedRoi');
    end
    function GetData(src,~)
        AncestorFigure = ancestor(src,'figure');
        StartWait(AncestorFigure);
        realhandle = findobj(ancestor(src,'axes'),'type','image');
        ImageData = realhandle.CData;
        RoiData = ImageData.*src.createMask;
        RoiData(RoiData==0) = NaN;
        Roi.Median = median(RoiData(:),'omitnan');
        Roi.Mean = mean(RoiData(:),'omitnan');
        Roi.Std = std(RoiData(:),'omitnan');
        Roi.CV = Roi.Std./Roi.Mean; Roi.CV(isnan(Roi.CV)) =0; 
        FH = findobj('Type','figure','-and','Name',strcat('ROI',num2str(src.UserData.ID)),'ToolBar','none','MenuBar','none');
        if ~isempty(FH)
            figure(FH);
        else
            FH = figure('NumberTitle','off','Name',strcat('ROI',num2str(src.UserData.ID)),'ToolBar','none','MenuBar','none');
        end
        
        FH.Color = src.Color;
        tbh = uitable(FH,'RowName',fieldnames(Roi),'Data',struct2array(Roi)');
        tbh.Position([3 4]) = tbh.Extent([3 4]);
        FH.Position = tbh.Position + [0 0 70 40];
        movegui(FH,'southwest')
        AddToFigureListStruct(FH,MFH,'side');
        StopWait(AncestorFigure);
    end
    function ApplyRoiToAll(src,~,ShapeHandle)
        FigureParent = ancestor(src,'figure');
        AxH = findobj(FigureParent.Children,'type','axes');
        for iaxh = 1:numel(AxH)
            ImH = findobj(AxH(iaxh).Children,'type','image');
            ImageData = ImH.CData;
            RoiData = ImageData.*ShapeHandle.createMask;
            RoiData(RoiData==0) = NaN;
            Roi.Median = median(RoiData(:),'omitnan');
            Roi.Mean = mean(RoiData(:),'omitnan');
            Roi.Std = std(RoiData(:),'omitnan');
            Roi.CV = Roi.Std./Roi.Mean; Roi.CV(isnan(Roi.CV)) =0;
            Header{iaxh} = AxH(iaxh).Title.String;
            data2write(iaxh,1) = Roi;
        end
        [Path ,FileName,~] = fileparts(MFH.UserData.FitFilePath);
        Name = fullfile(Path,[FileName,'_report.xls']);
        status=xlswrite(Name,[[{'Oper'};fieldnames(Roi)] [Header;struct2cell(data2write)]]);
        if(status)
            answer = questdlg('Open the report?','Open report','Yes','No','Yes');
                if strcmpi(answer,'yes')
                    winopen(Name);
                end
        end
    end


end