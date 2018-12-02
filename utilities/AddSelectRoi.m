function AddSelectRoi(parentfigure,object2attach)
cmh = uicontextmenu(parentfigure);
object2attach.UIContextMenu = cmh;
mmh = uimenu(cmh,'Label','Select roi on graph');
Shapes = {'Rectangle' 'Freehand' 'Circle'};
for is = 1:numel(Shapes)
    submh = uimenu(mmh,'Label',Shapes{is},'CallBack',{@SelectRoiOnGraph,Shapes{is}});
end


function SelectRoiOnGraph(src,event,shape)
RoiObjs = findobj('Type','images.roi');
ColorList ={'yellow' 'magenta' 'cyan' 'red' 'green' 'blue' 'white' 'black'};
ShapeHandle = images.roi.(shape);
if isempty(RoiObjs)
    ShapeHandle.UserData.ID = 1;
else
    ShapeHandle.UserData.ID = numel(RoiObjs)+1;
end
ShapeHandle.FaceAlpha = 0;
ShapeHandle.Color = ColorList{ShapeHandle.UserData.ID};
ShapeHandle.UIContextMenu.Children(1).MenuSelectedFcn = {@DeleteRoi,ShapeHandle};
addlistener(ShapeHandle,'DrawingFinished',@GetData);
draw(ShapeHandle)
addlistener(ShapeHandle,'ROIMoved',@GetData);

function GetData(src,event)
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
else
    FH=figure('NumberTitle','off','Name',strcat('ROI',num2str(src.UserData.ID),' - ',src.Tag),'ToolBar','none');
    src.UserData.FigRoiHandle = FH;
end
FH.Color = src.Color;
tbh = uitable(FH,'RowName',fieldnames(Roi),'Data',struct2array(Roi)');
tbh.Position([3 4]) = tbh.Extent([3 4]);
FH.Position = tbh.Position + [0 0 70 40];
StopWait(ancestor(src,'figure'));
end
end
    function DeleteRoi(src,event,roiobj)
        delete(roiobj.UserData.FigRoiHandle)
        delete(roiobj)
    end
end