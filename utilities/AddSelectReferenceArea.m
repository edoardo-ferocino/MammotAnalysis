function AddSelectReferenceArea(parentfigure,object2attach,Data,MFH)
[~,FileName,~] = fileparts(MFH.UserData.DispDatFilePath.String);
global FigureName;
FigureName = ['Reference Curve - ' FileName];
global FigureNameHandle;
FigureNameHandle = 'ReferenceHandle';
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
mmh = uimenu(cmh,'Text','Select reference area');
uimenu(mmh,'Text','Spot','Callback',{@ReferenceSpot,parentfigure});
areamh = uimenu(mmh,'Text','Area');
Shapes = {'Rectangle' 'Freehand' 'Circle'};
for is = 1:numel(Shapes)
    uimenu(areamh,'Text',Shapes{is},'CallBack',{@ReferenceArea,Shapes{is},object2attach});
end
pushbh = CreatePushButton(parentfigure,'String','Apply reference','Callback',{@ApplyReference},...
    'Units','normalized','Position',[0 0 0.2 0.05]);
pushbh.Tag = '0';
waitfor(pushbh,'Tag');


    function ReferenceSpot(src,~,figh)
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
        dch.UpdateFcn = {@PickReferenceCurveOnGraph,ObjMenu};
    end
    function output_txt=PickReferenceCurveOnGraph(src,~,~)
        AncestorFigure = ancestor(src,'figure');
        pos = src.Position; Xpos = pos(1); Ypos = pos(2);
        
        FH = findobj('Type','figure','-and','Name',FigureName);
        if ~isempty(FH)
            figure(FH);
        else
            FH=figure('NumberTitle','off','Name',FigureName);
        end
        
        movegui(FH,'northwest')
        
        %realhandle = findobj(ancestor(src,'axes'),'type','image');
        [~,~,numbin]=size(Data);
        output_txt = {['X: ',num2str(round(Xpos))],...
            ['Y: ',num2str(round(Ypos))],['Z: ',num2str(sum(Data(Ypos,Xpos,:))./MFH.UserData.CompiledHeaderData.McaTime)]};
        semilogy(1:numbin,squeeze(Data(Ypos,Xpos,:)));
        ylim([10 max(Data(:))]);
        figure(AncestorFigure);
        MinimizeFFS(AncestorFigure);
        AddToFigureListStruct(FH,MFH,'side');
        MFH.UserData.GateCurveReference.Type = 'Spot';
        MFH.UserData.GateCurveReference.Position = [Ypos Xpos];
    end

    function ReferenceArea(~,~,shape,object2attach)
        RoiObjs = findobj(object2attach,'Type','images.roi');
        ColorList ={'yellow' 'magenta' 'cyan' 'red' 'green' 'blue' 'white' 'black'};
        AxH = object2attach.Parent;
        ShapeHandle = images.roi.(shape)(AxH);
        ShapeHandle.UserData.Type = 'SelectRoi';
        if isempty(RoiObjs)
            ShapeHandle.UserData.ID = 1;
        else
            ShapeHandle.UserData.ID = numel(RoiObjs)+1;
        end
        ShapeHandle.FaceAlpha = 0;
        ColIDX = rem(ShapeHandle.UserData.ID,numel(ColorList));
        ShapeHandle.Color = ColorList{ColIDX};
        ShapeHandle.UIContextMenu.Children(...
            contains(lower({ShapeHandle.UIContextMenu.Children.Text}),'delete')).MenuSelectedFcn = {@DeleteRoi,ShapeHandle};
        addlistener(ShapeHandle,'DrawingFinished',@GetData);
        draw(ShapeHandle)
        addlistener(ShapeHandle,'ROIMoved',@GetData);
    end
    function DeleteRoi(~,~,roiobj)
        delete(roiobj.UserData.FigRoiHandle)
        delete(roiobj)
    end
%     function CopyRoi(~,~,roiobj)
%         MFH.UserData.CopiedRoi = roiobj;
%         icntxh = 1;
%         for ifigs = 1:numel(MFH.UserData.AllDataFigs)
%             obj2attach = findobj(MFH.UserData.AllDataFigs(ifigs),'Type','image');
%             for in = 1:numel(obj2attach)
%                 if isempty(obj2attach(in).UIContextMenu)
%                     cntxh = uicontextmenu(MFH.UserData.AllDataFigs(ifigs));
%                     obj2attach(in).UIContextMenu = cntxh;
%                 else
%                     cntxh = obj2attach(in).UIContextMenu;
%                 end
%                 umh = uimenu(cntxh,'Text','Paste roi','CallBack',{@PasteRoi,obj2attach(in)});
%                 MFH.UserData.TempMenuH(icntxh) = umh;
%                 icntxh = icntxh+1;
%             end
%         end
%         msgbox('Copied ROI object','Success','help');
%     end
%     function PasteRoi(~,~,obj2attach)
%         RoiObj = copyobj(MFH.UserData.CopiedRoi,obj2attach.Parent,'legacy');
%         RoiObj.UserData = rmfield(RoiObj.UserData,'FigRoiHandle');
%         AllImages = findall(MFH.UserData.AllDataFigs,'type','images.roi');
%         MaxIDPos = zeros(numel(AllImages),1);
%         for iAl = 1:numel(AllImages)
%             MaxIDPos(iAl) = AllImages(iAl).UserData.ID;
%         end
%         MaxVal = max(MaxIDPos);
%         RoiObj.UserData.ID = MaxVal+1;
%
%         ColorList ={'yellow' 'magenta' 'cyan' 'red' 'green' 'blue' 'white' 'black'};
%         RoiObj.UIContextMenu.Children(...
%             contains(lower({RoiObj.UIContextMenu.Children.Text}),'copy')).MenuSelectedFcn{2} = RoiObj;
%         RoiObj.UIContextMenu.Children(...
%             contains(lower({RoiObj.UIContextMenu.Children.Text}),'delete')).MenuSelectedFcn = {@DeleteRoi,RoiObj};
%         ColIDX = rem(RoiObj.UserData.ID,numel(ColorList))+1;
%         RoiObj.Color = ColorList{ColIDX};
%         GetData(RoiObj,RoiObj);
%         addlistener(RoiObj,'ROIMoved',@GetData);
%         for icntxh = 1:numel(MFH.UserData.TempMenuH)
%             MFH.UserData.TempMenuH(icntxh).delete;
%             delete(MFH.UserData.TempMenuH(icntxh));
%         end
%         MFH.UserData = rmfield(MFH.UserData,'TempMenuH');
%         MFH.UserData = rmfield(MFH.UserData,'CopiedRoi');
%     end
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
        FH = findobj('Type','figure','-and','Name',strcat('ROI',num2str(src.UserData.ID),' - ',src.Tag));
        if ~isempty(FH)
            figure(FH);
        else
            FH = figure('NumberTitle','off','Name',strcat('ROI',num2str(src.UserData.ID),' - ',src.Tag));
        end
        
        FH.Color = src.Color;
        tbh = uitable(FH,'RowName',fieldnames(Roi),'Data',struct2array(Roi)');
        tbh.Position([3 4]) = tbh.Extent([3 4]);
        FH.Position = tbh.Position + [0 0 70 40];
        movegui(FH,'northwest')
        
        tFH = findobj('Type','figure','-and','Name',FigureName);
        if ~isempty(tFH)
            FH(end+1) = tFH;
            figure(FH(end));
        else
            FH(end+1)=figure('NumberTitle','off','Name',FigureName);
        end
        
        dummyReference = Data;
        dummyReference(~repmat(src.createMask,[1 1 size(Data,3)])) = nan;
        dummyReference = mean(dummyReference,[1 2],'omitnan');
        dummyReference = squeeze(dummyReference);
        semilogy(1:size(Data,3),dummyReference);
        ylim([10 max(Data(:))]);
        
        AddToFigureListStruct(FH,MFH,'side');
        StopWait(AncestorFigure);
        MFH.UserData.GateCurveReference.Type = 'Area';
        MFH.UserData.GateCurveReference.Position = src.createMask;
    end
    function ApplyReference(~,~)
        if ~isfield(MFH.UserData,'GateCurveReference')
            msgbox('Please, select a ROI for the reference measure','Warning','help');
            return
        end
        numbin = size(Data,3);
        if strcmpi(MFH.UserData.GateCurveReference.Type,'Spot')
            Reference = Data(MFH.UserData.GateCurveReference.Position(1),...
                MFH.UserData.GateCurveReference.Position(2),:);
        else
            Reference = Data;
            Reference(~repmat(MFH.UserData.GateCurveReference.Position,[1 1 numbin])) = nan;
            Reference = mean(Reference,[1 2],'omitnan');
        end
        
        FH = findobj('Type','figure','-and','Name',['Reference for gates - ' FileName]);
        if ~isempty(FH)
            figure(FH);
        else
            FH=figure('NumberTitle','off','Name',['Reference for gates - ' FileName],'ToolBar','none');
        end
        
        Reference = squeeze(Reference);
        semilogy(1:numbin,Reference);
        MFH.UserData.GateCurveReference.CurveReference = Reference;
                
        AddToFigureListStruct(FH,MFH,'side');
        pushbh.Tag = '';
    end
end