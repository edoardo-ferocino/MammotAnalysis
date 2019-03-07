function AddCorrectPixels(parentfigure,object2attach,Wave,MFH)
PercFract = 95;
Threshold = 1000;
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
mmh = uimenu(cmh,'Text','Correct pixels');
Shapes = {'Line' 'Point'};
for is = 1:numel(Shapes)
    uimenu(mmh,'Text',Shapes{is},'CallBack',{@CorrectPixels,Shapes{is},object2attach});
end

    function CorrectPixels(~,~,shape,object2attach)
        RoiObjs = findobj(object2attach,'Type','images.roi');
        ColorList ={'red'};
        AxH = object2attach.Parent;
        ShapeHandle = images.roi.(shape)(AxH);
        ShapeHandle.UserData.Type = 'CorrectPixels';
        if isempty(RoiObjs)
            ShapeHandle.UserData.ID = 1;
        else
            ShapeHandle.UserData.ID = numel(RoiObjs)+1;
        end
        %ShapeHandle.FaceAlpha = 0;
        ColIDX = rem(ShapeHandle.UserData.ID,numel(ColorList))+1;
        ShapeHandle.Color = ColorList{ColIDX};
        %ShapeHandle.StripeColor = 'yellow';
        %uimenu(ShapeHandle.UIContextMenu,'Text','Copy DefineBorder ROI','CallBack',{@CopyRoi,ShapeHandle});
        submH = uimenu(ShapeHandle.UIContextMenu,'Text','Apply CorrectPixels to ROI', 'Callback',{@ApplyRoi,ShapeHandle} );
        %uimenu(submH,'Text','Delete external','CallBack',{@ApplyRoi,ShapeHandle,'external'});
        %uimenu(submH,'Text','Delete internal','CallBack',{@ApplyRoi,ShapeHandle,'internal'});
        draw(ShapeHandle)
        %Mask = Mask + ShapeHandle.CreateMask;
    end

    function ApplyRoi(src,~,ShapeHandle,Deletetype)
        FigureParent = ancestor(src,'figure');
        StartWait(FigureParent);
        FH = copyobj(FigureParent,groot,'legacy');
        AxH = findobj(FH.Children,'type','axes');
        for iaxh = 1:numel(AxH)
            ImH = findobj(AxH(iaxh).Children,'type','image');
            shapeh = findobj(ShapeHandle.Parent.Children,'type','images.roi');
            Mask = zeros(size(Wave(1).Curves,1),size(Wave(1).Curves,2));
            for ish = 1:numel(shapeh)
                if strcmpi(shapeh(ish).UserData.Type,'CorrectPixels')
                      ymin = min(round(shapeh(ish).Position(:,2)));
                      ymax = max(round(shapeh(ish).Position(:,2)));
                      xmin = min(round(shapeh(ish).Position(:,1)));
                      xmax = max(round(shapeh(ish).Position(:,1)));
                    
                    if strcmpi(shapeh(ish).Type,'images.roi.point')
                        Mask(ymin,xmax) = 1; %non esiste createMask per i points
                    else
                        Mask = Mask + shapeh(ish).createMask;
                    end
        
                    for iw = 1:size(Wave,2)
                      Wave(iw).Curves(ymin:ymax,xmin:xmax,:) = repmat(mean([Wave(iw).Curves(ymax+1,xmin:xmax,:); Wave(iw).Curves(ymin-1,xmin:xmax,:)],1),ymax-ymin+1,1);
                      Wave(iw).CountsAllChan = sum(Wave(iw).Curves,3);
                    end
                    
                    ImH.CData = ImH.CData.*~Mask + Wave(1).CountsAllChan.*Mask;
                    tshapeh = shapeh(ish);
                    PercVal = GetPercentile(ImH.CData,PercFract);
                    ImH.Parent.CLim = [0 PercVal];                   
                end
            end
        end
        newName = FH.Name;
        while ~isempty(findobj('name',newName,'type','figure'))
           newName = [newName '-Corrected'];  %#ok<AGROW>
        end
        FH.Name = newName;
        shapeh = findobj(FH,'type','images.roi');
        delete(shapeh);
        AddToFigureListStruct(FH,MFH,'data')
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
        answer = questdlg('Use the corrected data for analysis?','Cropped data','Yes','No','No');
        if strcmpi(answer,'yes')
           msh = msgbox('Please run again the analysis','Success','help');
           MFH.UserData.DataMask = Mask; 
           %MFH.UserData.DataMaskDelType = Deletetype;
           %MFH.UserData.DataMaskHandle = tshapeh;
        end
        movegui(msh,'center');
    end

end