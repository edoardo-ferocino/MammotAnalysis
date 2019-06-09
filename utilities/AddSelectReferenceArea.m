function AddSelectReferenceArea(parentfigure,object2attach,Data,MFH)
[~,FileName]=fileparts(parentfigure.UserData.DatFilePath);
ReferenceCurveFigureName = ['Reference Curve - ' FileName];
if isempty(object2attach.UIContextMenu)
cmh = uicontextmenu(parentfigure);
object2attach.UIContextMenu = cmh;
else
cmh = object2attach.UIContextMenu;
end
mmh = uimenu(cmh,'Text','Select reference area for gates');
uimenu(mmh,'Text','Spot','Callback',{@ReferenceSpot,parentfigure});
areamh = uimenu(mmh,'Text','Area');
Shapes = {'Rectangle' 'Freehand' 'Circle'};
for is = 1:numel(Shapes)
uimenu(areamh,'Text',Shapes{is},'CallBack',{@ReferenceArea,Shapes{is},object2attach});
end
preunits = parentfigure.Units; parentfigure.Units = 'normalized';
CreatePushButton(parentfigure,'units','normalized','String','Apply reference','Position',[0 0 0.05 0.05],'CallBack',{@CalcReferenceGate,parentfigure,MFH});
parentfigure.Units = preunits;

function ReferenceSpot(src,~,figh)
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
    dch.UpdateFcn = {@PickReferenceCurveOnGraph,ObjMenu};
end
function output_txt=PickReferenceCurveOnGraph(src,~,~)
    AncestorFigure = ancestor(src,'figure');
    pos = src.Position; Xpos = pos(1); Ypos = pos(2);
    FH=CreateOrFindFig(ReferenceCurveFigureName,'NumberTitle','off');
    FH.UserData.FigCategory = 'ReferencePickCurve';
    FH.Color = 'blue';
    movegui(FH,'northwest')
    [~,~,numbin]=size(Data);
    semilogy(1:numbin,squeeze(Data(Ypos,Xpos,:)));
    xlim([1 numbin]);
    ylim([10 max(Data(:))]);
    if isfield(parentfigure.UserData,'TrsSet')
        Counts = sum(Data(Ypos,Xpos,:),3);
        TrsSet = parentfigure.UserData.TrsSet;
        RelCounts = zeros(1,numel(MFH.UserData.Wavelengths)+1);
        RelCounts(1) = (mean(Data(Ypos,Xpos,str2double(MFH.UserData.BkgFirst.String):str2double(MFH.UserData.BkgLast.String)))*numbin)./Counts*100;
        for iw = 2:numel(MFH.UserData.Wavelengths)+1
            RelCounts(iw) = (sum(Data(Ypos,Xpos,TrsSet.Roi(iw-1,2)+1:TrsSet.Roi(iw-1,3)+1),3)-mean(Data(Ypos,Xpos,str2double(MFH.UserData.BkgFirst.String):str2double(MFH.UserData.BkgLast.String)))*(numel(TrsSet.Roi(iw-1,2)+1:TrsSet.Roi(iw-1,3)+1)))./Counts * 100;
           [CurveWidth(iw),CurveBar(iw)]=CalcWidth(Data(Ypos,Xpos,TrsSet.Roi(iw-1,2)+1:TrsSet.Roi(iw-1,3)+1),0.5);
            vline(TrsSet.Roi(iw-1,3)+1,'r','');
        end
    end
    CurveWidth = CurveWidth.*parentfigure.UserData.CompiledHeaderData.McaFactor;
    output_txt = [...
            {strcat('X: ',num2str(round(Xpos)))},...
            {strcat('Y: ',num2str(round(Ypos)))},...
            {strcat('Countrate: ',num2str(sum(Data(Ypos,Xpos,:))./parentfigure.UserData.CompiledHeaderData.McaTime))},...
            {strcat(char('Bkg',num2str(MFH.UserData.Wavelengths')),num2str(RelCounts',':%.0f%%, '),num2str(RelCounts'./100*Counts,'BkgFree: %g, '),num2str(CurveWidth','width: %.0f ps, '),num2str(CurveBar','Bar: %.1f ch'))}];
    AddToFigureListStruct(FH,MFH,'side')
    figure(AncestorFigure);
    MinimizeFFS(AncestorFigure);

    parentfigure.UserData.Gate.CurveReference.Type = 'Spot';
    parentfigure.UserData.Gate.CurveReference.Position = [Ypos Xpos];
    parentfigure.UserData.Gate.CurveReference.Curve = squeeze(Data(Ypos,Xpos,:));
end

function ReferenceArea(~,~,shape,object2attach)
    AxH = ancestor(object2attach,'axes');
    ShapeHandle = images.roi.(shape)(AxH);
    ShapeHandle.UserData.Type = 'SelectRoi';
    if ~isfield(MFH.UserData,ShapeHandle.UserData.Type)
        ShapeHandle.UserData.ID = 1;
        MFH.UserData.(ShapeHandle.UserData.Type).ID = 1;
    else
        MFH.UserData.(ShapeHandle.UserData.Type).ID = ...
            MFH.UserData.(ShapeHandle.UserData.Type).ID+1;
        ShapeHandle.UserData.ID = MFH.UserData.(ShapeHandle.UserData.Type).ID;
    end
    ShapeHandle.FaceAlpha = 0;
    ShapeHandle.Color = 'blue';
    ShapeHandle.StripeColor = 'green';
    ShapeHandle.UIContextMenu.Children(...
        contains(lower({ShapeHandle.UIContextMenu.Children.Text}),'delete')).Text = ...
        ['Delete Reference ROI ',num2str(ShapeHandle.UserData.ID)];
    ShapeHandle.UIContextMenu.Children(...
        contains(lower({ShapeHandle.UIContextMenu.Children.Text}),'delete')).MenuSelectedFcn = {@DeleteRoi,ShapeHandle};
    %uimenu(ShapeHandle.UIContextMenu,'Text',['Copy Reference ROI ',num2str(ShapeHandle.UserData.ID)],'CallBack',{@CopyRoi,ShapeHandle});
    %uimenu(ShapeHandle.UIContextMenu,'Text',['Apply Reference ROI ',num2str(ShapeHandle.UserData.ID),' to all axes'],'CallBack',{@CreateLinkDataFigure,ShapeHandle});
    addlistener(ShapeHandle,'DrawingFinished',@GetData);
    draw(ShapeHandle)
    addlistener(ShapeHandle,'ROIMoved',@GetData);
end
function DeleteRoi(~,~,RoiObj)
    FH=findobj(groot,'type','figure','Name',strcat('Reference ROI - ',num2str(RoiObj.UserData.ID)));
    delete(RoiObj)
    delete(FH);
    FH=findobj(groot,'type','figure','Name',ReferenceCurveFigureName);
    delete(FH);
end
function GetData(src,event)
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
        Roi.Max = max(RoiData(:));
        Roi.Min = min(RoiData(:));
        Roi.Points = sum(isfinite(RoiData(:)));
        FH=CreateOrFindFig(strcat('Reference ROI - ',num2str(src.UserData.ID)),'NumberTitle','off','ToolBar','none','MenuBar','none');
        FH.Color = src.Color;
        FH.UserData.FigCategory = 'ReferenceROI';
        tbh = uitable(FH,'RowName',fieldnames(Roi),'Data',struct2array(Roi)');
        tbh.Position([3 4]) = tbh.Extent([3 4]);
        FH.Position([3 4]) = tbh.Position([3 4]) + [70 40];
        movegui(FH,'southwest')
        if ~strcmpi(event.EventName,'roimoved')
            AddToFigureListStruct(FH,MFH,'side');
        end
        StopWait(AncestorFigure);
        
        FH=CreateOrFindFig(ReferenceCurveFigureName,'NumberTitle','off');
        FH.Color = src.Color;
        FH.UserData.FigCategory = 'ReferencePickCurve';
        ReferenceCurve = Data;
        ReferenceCurve(~repmat(src.createMask,[1 1 size(Data,3)])) = nan;
        ReferenceCurve = mean(ReferenceCurve,[1 2],'omitnan');
        ReferenceCurve = squeeze(ReferenceCurve);
        semilogy(1:size(Data,3),ReferenceCurve);
        ylim([10 max(Data(:))]);
        movegui(FH,'northwest');
        
        AddToFigureListStruct(FH,MFH,'side');
        StopWait(AncestorFigure);
        parentfigure.UserData.Gate.CurveReference.Type = 'Area';
        parentfigure.UserData.Gate.CurveReference.Position = src.createMask;
        parentfigure.UserData.Gate.CurveReference.Curve = ReferenceCurve;
    end
end