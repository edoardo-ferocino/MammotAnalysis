function ApplyMeasureTool(mtoolobj,completetoolname,toolname)
nobjs = numel(mtoolobj);
dosetstatus = false;
dosethistory = true;
for iobj = 1:nobjs
    maxesactvobj = mtoolobj(iobj).Axes;
    mtoolactvobj = mtoolobj(iobj);
    switch toolname{1}
        case 'distance'
            h = images.roi.Line(maxesactvobj.axes,'Color',[0, 0, 0.5625]);
            addlistener(h,'MovingROI',@(src,event)updateLabel(src,event,'Distance',maxesactvobj.Parent.ScaleFactor));
            draw(h);
        case 'perimeter'
            if mtoolactvobj.nRoi == 0, continue; end
            dosetstatus = true;
            selshapes = vertcat(mtoolactvobj.Roi(vertcat(mtoolactvobj.Roi.Selected)).Shape);
            for is = 1:numel(selshapes)
                addlistener(selshapes(is),'MovingROI',@(src,event)updateLabel(src,event,'Perimeter',maxesactvobj.Parent.ScaleFactor));
                updateLabel(selshapes(is),[],'Perimeter',maxesactvobj.Parent.ScaleFactor);
            end
        case 'area'
            if mtoolactvobj.nRoi == 0, continue; end
            dosetstatus = true;
            selshapes = vertcat(mtoolactvobj.Roi(vertcat(mtoolactvobj.Roi.Selected)).Shape);
            for is = 1:numel(selshapes)
                addlistener(selshapes(is),'MovingROI',@(src,event)updateLabel(src,event,'Area',maxesactvobj.Parent.ScaleFactor));
                updateLabel(selshapes(is),[],'Area',maxesactvobj.Parent.ScaleFactor);
            end
    end
    if dosetstatus==true
        mtoolactvobj.Status.(completetoolname) = 1;
    end
    if dosethistory==true
        history.roi = mtoolactvobj.Roi;
        history.data = maxesactvobj.ImageData;
        history.toolname = completetoolname;
        history.message = 'Measure distance tool';
        notify(maxesactvobj,'ToolApplied',historyeventdata(history));
    end
end

end
function updateLabel(shapeobj,~,type,ScaleFactor)
switch type
    case 'Distance'
        pos = shapeobj.Position;
        diffPos = diff(pos);
        mag = hypot(diffPos(1),diffPos(2));
        mag = mag*ScaleFactor;
        set(shapeobj,'Label',[num2str(mag,'%30.1f') ' mm'])
    case 'Perimeter'
        switch shapeobj.Type
            case 'images.roi.rectangle'
                perimeter = (shapeobj.Position(3)+shapeobj.Position(4))*2;
            case 'images.roi.freehand'
                deltas=diff(shapeobj.Position,1,1);
                distances = hypot(deltas(:,1),deltas(:,2));
                perimeter = sum(distances);
            case 'images.roi.circle'
                perimeter = 2*pi*shapeobj.Radius;
        end
        perimeter = perimeter*ScaleFactor;
        set(shapeobj,'Label',['Perimeter: ' num2str(perimeter,'%30.1f') ' mm'])
    case 'Area'
        switch shapeobj.Type
            case 'images.roi.rectangle'
                area = shapeobj.Position(3)*shapeobj.Position(4);
            case 'images.roi.freehand'
                area = shapeobj.createMask;
                area = sum(area(:))*4;
            case 'images.roi.circle'
                area = pi*(shapeobj.Radius)^2;
        end
        area = area*ScaleFactor;
        set(shapeobj,'Label',['Area: ' num2str(area,'%30.1f') ' mm'])
end
end