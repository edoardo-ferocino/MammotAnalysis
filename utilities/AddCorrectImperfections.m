function AddCorrectImperfections(parentfigure,object2attach,MFH,RawData)
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
mmh = uimenu(cmh,'Text','Correct image');
uimenu(mmh,'Text','Spot','CallBack',{@DefineImperfection,Shapes{is},object2attach});
uimenu(mmh,'Text','Row','CallBack',{@DefineImperfection,Shapes{is},object2attach});
Shapes = {'Rectangle' 'Freehand'};
for is = 1:numel(Shapes)
    uimenu(mmh,'Text',Shapes{is},'CallBack',{@DefineImperfection,Shapes{is},object2attach});
end
    function DefineImperfetcion(~,~,shape,object2attach)
        RoiObjs = findobj(object2attach,'Type','images.roi');
        ColorList ={'red'};
        AxH = object2attach.Parent;
        ShapeHandle = images.roi.(shape)(AxH);
        ShapeHandle.UserData.Type = 'CorrectImperfection';
        if isempty(RoiObjs)
            ShapeHandle.UserData.ID = 1;
        else
            ShapeHandle.UserData.ID = numel(RoiObjs)+1;
        end
        ShapeHandle.FaceAlpha = 0;
        ColIDX = rem(ShapeHandle.UserData.ID,numel(ColorList))+1;
        ShapeHandle.Color = ColorList{ColIDX};
        ShapeHandle.StripeColor = 'green';
        %uimenu(ShapeHandle.UIContextMenu,'Text','Copy DefineBorder ROI','CallBack',{@CopyRoi,ShapeHandle});
        submH = uimenu(ShapeHandle.UIContextMenu,'Text','Load Correction','Callback',{@LoadCorrection,ShapeHandle});
        %uimenu(submH,'Text','Delete external','CallBack',{@ApplyRoi,ShapeHandle,'external'});
        %uimenu(submH,'Text','Delete internal','CallBack',{@ApplyRoi,ShapeHandle,'internal'});
        draw(ShapeHandle) 
    end
    function LoadCorrection(src,event,shapehandle)
     IMH = ancestor(src,'image');
     AXH = ancestor(src,'axes');
     NEWIMH = imagesc(AXH,IMH.CData);
     Original = IMH.CData;
     IMH.Colormap = 
     [Numy,Numx,Numchan,NumBin] = size(RawData);   
     rawcountsmap = squeeze(sum(RawData,[3 4]));
     indxs = find(shapehandle.createMask);
     for in = 1:numel(indxs)
        if rawcountsmap(indxs(in)) <= 600000
            IMH.CData(indxs(in)) = 
        else
            
        end
     end
     bcountsmap = rawcountsmap;
     bcountsmap();
    end
end