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
        ShapeHandle.Color = rand(1,3);
        ShapeHandle.UIContextMenu.Children(...
            contains(lower({ShapeHandle.UIContextMenu.Children.Text}),'delete')).Text = ...
            ['Delete ',num2str(ShapeHandle.UserData.ID),' ',shape];
        uimenu(ShapeHandle.UIContextMenu,'Text',['Copy ROI ',num2str(ShapeHandle.UserData.ID)],'CallBack',{@CopyRoi,ShapeHandle});
        uimenu(ShapeHandle.UIContextMenu,'Text',['Apply ROI ',num2str(ShapeHandle.UserData.ID),' to all axes'],'CallBack',{@ApplyRoiToAll,ShapeHandle});
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
        RoiObj.Color = rand(1,3);
        GetData(RoiObj,RoiObj);
        addlistener(RoiObj,'ROIMoved',@GetData);
        for icntxh = 1:numel(MFH.UserData.TempMenuH)
            MFH.UserData.TempMenuH(icntxh).delete;
            delete(MFH.UserData.TempMenuH(icntxh));
        end
        MFH.UserData = rmfield(MFH.UserData,'TempMenuH');
        MFH.UserData = rmfield(MFH.UserData,'CopiedRoi');
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
        FH=CreateOrFindFig(strcat('ROI - ',num2str(src.UserData.ID)),false,'NumberTitle','off','ToolBar','none','MenuBar','none');
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
        StartWait(FigureParent);
        UnderScoreName = '_AllRoi';
        [Path ,FileName,~] = fileparts(FigureParent.UserData.FHDataFilePath);
        Name = fullfile(Path,[FileName,UnderScoreName,'.xls']);
        ifh = 1;
        LookForName = FileName;
        IsUnderscore=strfind(LookForName,'_');
        if IsUnderscore
            IsUnderscore = IsUnderscore-1;
            LookForName=LookForName(1:IsUnderscore);
        end
        for inf = 1:numel(MFH.UserData.AllDataFigs)
            if strfind(MFH.UserData.AllDataFigs(inf).Name,LookForName)
                FH(ifh) = MFH.UserData.AllDataFigs(inf); 
                ifh=ifh+1;
            end
        end
        AllData = [];
        AllHeader = [];
        ir=1;
        for ifh =1:numel(FH)
            if(contains(FH(ifh).Name,'optical prop','IgnoreCase',true)&&~contains(FH(ifh).Name,'globalview','IgnoreCase',true))
                continue;
            end
            AxH = findobj(FH(ifh).Children,'type','axes');
            clear data2write Header;
            for iaxh = 1:numel(AxH)
                ImH = findobj(AxH(iaxh).Children,'type','image');
                RoiObj(ir) = copyobj(ShapeHandle,AxH(iaxh),'legacy');
                ir=ir+1;
                ImageData = ImH.CData;
                RoiData = ImageData.*ShapeHandle.createMask;
                RoiData(RoiData==0) = NaN;
                Roi.Median = median(RoiData(:),'omitnan');
                Roi.Mean = mean(RoiData(:),'omitnan');
                Roi.Std = std(RoiData(:),'omitnan');
                Roi.CV = Roi.Std./Roi.Mean; Roi.CV(isnan(Roi.CV)) =0;
                Header{iaxh} = AxH(iaxh).Title.String; %#ok<*AGROW>
                data2write(iaxh,1) = Roi;
            end
            AllHeader = [AllHeader Header];
            if(ifh==1), AllData = data2write;
            else, AllData = [AllData;data2write]; end
        end
        if isfile(Name)
            answer = inputdlg('Type different underscore or leave blank to overwrite','File already exist');
            if numel(answer)==0
                delete(RoiObj);
                return
            end
            if ~isempty(answer{1})
                UnderScoreName=answer{1};
                Name = fullfile(Path,[LookForName,UnderScoreName,'.xls']);
            end
        end
        if(isfield(FH(1).UserData,'AllData'))
        fitdata = [[{'View'}; repmat(FH(1).UserData.AllData.View(1),numel(fieldnames(Roi)),1) ] ...
            [{'Breast'}; repmat(FH(1).UserData.AllData.Breast(1),numel(fieldnames(Roi)),1) ] ...
            [{'Session'}; repmat(num2cell(FH(1).UserData.AllData.Session(1)),numel(fieldnames(Roi)),1) ] ...
            [{'Repetition'}; repmat(num2cell(FH(1).UserData.AllData.Repetition(1)),numel(fieldnames(Roi)),1)] ];
        else
            fitdata = [];
        end
        if isfield(ShapeHandle,'Vertices')
           vertdata =  [{'TL X' 'TL Y' 'TR X' 'TR Y' 'BR X' 'BR Y' 'BL X' 'BL Y'};repmat(num2cell(reshape(ShapeHandle.Vertices',1,numel(ShapeHandle.Vertices))),numel(fieldnames(Roi)),1)];
        else
            vertdata = [];
        end
        status=xlswrite(Name,[[{'FileName'}; repmat({LookForName},numel(fieldnames(Roi)),1) ] ...
            fitdata...
            [{'Oper'};fieldnames(Roi)] [AllHeader;struct2cell(AllData)]...
            vertdata]);
        if(status)
            answer = questdlg('Open the report?','Open report','Yes','No','Yes');
            if strcmpi(answer,'yes')
                winopen(Name);
            end
        end
        if(status)
            answer = questdlg('Save the figure?','Save figure','Yes','No','Yes');
            if strcmpi(answer,'yes')
                StartWait(FigureParent);
                PathName =uigetdircustom('Select destination');
                if PathName == 0, delete(RoiObj);return, end
                FullPath = fullfile(PathName,FigureParent.Name);
                warning off
                save_figure(FullPath,'-png','-pdf');
                warning on
                msgbox('Figure saved','Success','Help');
                StopWait(FigureParent);
            end
        end
        delete(RoiObj);
    end
end