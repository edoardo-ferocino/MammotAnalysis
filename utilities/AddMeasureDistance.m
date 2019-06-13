function AddMeasureDistance(parentfigure,object2attach,MFH)
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
sz = size(object2attach.CData);
myData.Units = 'mm';
myData.MaxValue = hypot(sz(1),sz(2));
myData.Colormap = hot;
myData.ScaleFactor = 1;
if isfield(parentfigure.UserData,'ScaleFactor')
    myData.ScaleFactor = parentfigure.UserData.ScaleFactor;
end
uimenu(cmh,'Text','Measure distance','CallBack',{@MeasureDistance,myData});

    function MeasureDistance(cmh,~,myData)
        if strcmpi(cmh.Checked,'off')
            cmh.Checked = 'on';
        else
            cmh.Checked = 'off';
            object2attach.ButtonDownFcn = [];
            return
        end
            
        object2attach.ButtonDownFcn = {@startDrawing,myData};
    end
    function startDrawing(~,event,myData)
        if event.Button ~= 1
            return;
        end
        hAx = ancestor(object2attach,'axes');
        h = images.roi.Line('Color',[0, 0, 0.5625],'UserData',myData);
        addlistener(h,'MovingROI',@updateLabel);
        %addlistener(h,'ROIClicked',@updateUnits);
        cp = hAx.CurrentPoint;
        cp = [cp(1,1) cp(1,2)];
        h.beginDrawingFromPoint(cp);
        c = h.UIContextMenu;
        uimenu(c,'Label','Delete All','Callback',@deleteAll);
    end
    function updateLabel(src,evt)
        pos = evt.Source.Position;
        diffPos = diff(pos);
        mag = hypot(diffPos(1),diffPos(2));
        %color = src.UserData.Colormap(ceil(64*(mag/src.UserData.MaxValue)),:);
        mag = mag/src.UserData.ScaleFactor;
        set(src,'Label',[num2str(mag,'%30.1f') ' ' src.UserData.Units]);%,'Color',color);
    end
    function deleteAll(src,~)
        hFig = ancestor(src,'figure');
        hROIs = findobj(hFig,'Type','images.roi.Line');
        delete(hROIs)
        
    end
end