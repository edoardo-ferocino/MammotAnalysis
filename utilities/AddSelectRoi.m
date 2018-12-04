function AddSelectRoi(parentfigure,object2attach,MFH)
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
mmh = uimenu(cmh,'Label','Select roi on graph');
Shapes = {'Rectangle' 'Freehand' 'Circle'};
for is = 1:numel(Shapes)
    uimenu(mmh,'Label',Shapes{is},'CallBack',{@SelectRoiOnGraph,Shapes{is},object2attach});
end


    function SelectRoiOnGraph(~,~,shape,object2attach)
        RoiObjs = findobj('Type','images.roi');
        ColorList ={'yellow' 'magenta' 'cyan' 'red' 'green' 'blue' 'white' 'black'};
        AxH = object2attach.Parent;
        ShapeHandle = images.roi.(shape)(AxH);
        if isempty(RoiObjs)
            ShapeHandle.UserData.ID = 1;
        else
            ShapeHandle.UserData.ID = numel(RoiObjs)+1;
        end
        ShapeHandle.FaceAlpha = 0;
        ShapeHandle.Color = ColorList{ShapeHandle.UserData.ID};
        ShapeHandle.UIContextMenu.Children(1).MenuSelectedFcn = {@DeleteRoi,ShapeHandle};
        uimenu(ShapeHandle.UIContextMenu,'Label','Copy ROI','CallBack',{@CopyRoi,ShapeHandle});
        addlistener(ShapeHandle,'DrawingFinished',@GetData);
        draw(ShapeHandle)
        addlistener(ShapeHandle,'ROIMoved',@GetData);
    end
    function DeleteRoi(~,~,roiobj)
        delete(roiobj.UserData.FigRoiHandle)
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
                umh = uimenu(cntxh,'Label','Paste roi','CallBack',{@PasteRoi,obj2attach(in)});
                MFH.UserData.TempMenuH(icntxh) = umh;
                icntxh = icntxh+1;
            end
        end
        msgbox('Copied ROI object','Success','help');
    end
    function PasteRoi(~,~,obj2attach)
        copyobj(MFH.UserData.CopiedRoi,obj2attach.Parent,'legacy');
        RoiObj = findobj(obj2attach.Parent.Children,'Type','images.roi');
        RoiObj.UserData = rmfield(RoiObj.UserData,'FigRoiHandle');
        RoiObj.UserData.ID = RoiObj.UserData.ID+1;
        ColorList ={'yellow' 'magenta' 'cyan' 'red' 'green' 'blue' 'white' 'black'};
        RoiObj.UIContextMenu.Children(1).MenuSelectedFcn{2} = RoiObj;
        RoiObj.UIContextMenu.Children(2).MenuSelectedFcn = {@DeleteRoi,RoiObj};
        RoiObj.Color = ColorList{RoiObj.UserData.ID};
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
        StartWait(ancestor(src,'figure'));
        nchild = numel(src.Parent.Children);
        for inc = 1:nchild
            if strcmpi(src.Parent.Children(inc).Type,'image')
                realhandle = src.Parent.Children(inc);
            end
        end
        
        Xv = realhandle.XData; Yv = realhandle.YData;
        Data = realhandle.CData;
        [numy,numx]=size(Data);
        if (numel(Xv)==2)
            Xv = linspace(Xv(1),Xv(2),numx);
            Yv = linspace(Yv(1),Yv(2),numy);
        end
        RoiData = zeros(size(Data));
        for iy=1:numy
            for ix=1:numx
                if(src.inROI(Xv(ix),Yv(iy)))
                    RoiData(iy,ix) = Data(iy,ix);
                end
            end
        end
        RoiData(RoiData==0) = nan;
        Roi.Median = median(RoiData(:),'omitnan');
        Roi.Mean = mean(RoiData(:),'omitnan');
        Roi.Std = std(RoiData(:),'omitnan');
        Roi.CV = Roi.Std./Roi.Mean;
        if (isfield(src.UserData,'FigRoiHandle'))
            FH = src.UserData.FigRoiHandle;
            FH.UserData.RoiObjHandle = src;
            figure(FH)
        else
            FH=figure('NumberTitle','off','Name',strcat('ROI',num2str(src.UserData.ID),' - ',src.Tag),'ToolBar','none');
            src.UserData.FigRoiHandle = FH;
            if ~isfield(MFH.UserData,'SideFigs')
                MFH.UserData.SideFigs = FH;
            else
                MFH.UserData.SideFigs(end+1) = FH;
            end
        end
        FH.Color = src.Color;
        tbh = uitable(FH,'RowName',fieldnames(Roi),'Data',struct2array(Roi)');
        tbh.Position([3 4]) = tbh.Extent([3 4]);
        FH.Position = tbh.Position + [0 0 70 40];
        StopWait(ancestor(src,'figure'));
    end
end