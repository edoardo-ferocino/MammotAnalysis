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
            ['Delete ROI ',num2str(ShapeHandle.UserData.ID)];
        ShapeHandle.UIContextMenu.Children(...
            contains(lower({ShapeHandle.UIContextMenu.Children.Text}),'delete')).MenuSelectedFcn = {@DeleteRoi,ShapeHandle};
        uimenu(ShapeHandle.UIContextMenu,'Text',['Copy ROI ',num2str(ShapeHandle.UserData.ID)],'CallBack',{@CopyRoi,ShapeHandle});
        uimenu(ShapeHandle.UIContextMenu,'Text',['Apply ROI ',num2str(ShapeHandle.UserData.ID),' to all axes'],'CallBack',{@CreateLinkDataFigure,ShapeHandle});
        addlistener(ShapeHandle,'DrawingFinished',@GetData);
        draw(ShapeHandle)
        addlistener(ShapeHandle,'ROIMoved',@GetData);
    end
    function DeleteRoi(~,~,RoiObj)
        FH=findobj(groot,'type','figure','Name',strcat('ROI - ',num2str(RoiObj.UserData.ID)));
        delete(RoiObj)
        delete(FH);
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
            contains(lower({RoiObj.UIContextMenu.Children.Text}),'copy')).Text = ['Copy ROI ',num2str(RoiObj.UserData.ID)];
        RoiObj.UIContextMenu.Children(...
            contains(lower({RoiObj.UIContextMenu.Children.Text}),'delete')).MenuSelectedFcn = {@DeleteRoi,RoiObj};
        RoiObj.UIContextMenu.Children(...
            contains(lower({RoiObj.UIContextMenu.Children.Text}),'delete')).Text = ['Delete ROI ',num2str(RoiObj.UserData.ID)];
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
        FH=CreateOrFindFig(strcat('ROI - ',num2str(src.UserData.ID)),'NumberTitle','off','ToolBar','none','MenuBar','none');
        FH.Color = src.Color;
        FH.UserData.FigCategory = 'ROI';
        tbh = uitable(FH,'RowName',fieldnames(Roi),'Data',struct2array(Roi)');
        tbh.Position([3 4]) = tbh.Extent([3 4]);
        FH.Position = tbh.Position + [0 0 70 40];
        movegui(FH,'southwest')
        if ~strcmpi(event.EventName,'roimoved')
            AddToFigureListStruct(FH,MFH,'side');
        end
        StopWait(AncestorFigure);
    end
    function CreateLinkDataFigure(~,~,ShapeHandle)
        FH = CreateOrFindFig('Link Figures','NumberTitle','off','Toolbar','None','MenuBar','none');
        clf(FH);
        FH.UserData.FigCategory = 'LinkFigures';
        actualnameslist = MFH.UserData.ListFigures.String(~contains(MFH.UserData.ListFigures.String,'Select filters'));
        numfig = numel(actualnameslist);
        for ifigs = 1:numfig
            CH(ifigs) = CreateContainer(FH,'BorderType','none','Units','Normalized','Position',[0 (1/numfig)*(ifigs-1) 1 1/numfig]);%,'BorderType','none');
            CreateEdit(CH(ifigs),'String',actualnameslist{ifigs},'HorizontalAlignment','Left',...
                'Units','Normalized','OuterPosition',[0 0 0.7 1]);
            CBH(ifigs) = CreateCheckBox(CH(ifigs),'String','Link','Units','Normalized','Position',[0.7 0 0.1 1]);
        end
        EH=CreateEdit(FH,'String','Linked Name(Type)','HorizontalAlignment','Left',...
            'Units','Normalized','Position',[0.80 0.08 0.20 0.08]);
        CreatePushButton(FH,'Units','Normalized','Position',[0.90 0 0.10 0.08],'String','Link&Run','Callback',{@ApplyRoiToAll,ShapeHandle,CBH,EH});
        AddToFigureListStruct(FH,MFH,'side');
    end
    function ApplyRoiToAll(src,~,ShapeHandle,CheckBoxHandle,NameHandle)
        StartWait(ancestor(src,'figure'));
        actualfhlist = MFH.UserData.AllDataFigs(~contains(MFH.UserData.ListFigures.String,'Select filters'));
        FH=actualfhlist(logical([CheckBoxHandle.Value]));
        FigureParent = ancestor(ShapeHandle,'figure');
        StartWait(FigureParent);
        UnderScoreName = '_AllRoi';
        [Path ,FileName,~] = fileparts(FigureParent.UserData.DataFilePath);
        Name = fullfile(Path,[FileName,UnderScoreName,'.xls']);
        AllData2Write = [];
        AllHeader = [];
        ir=1;
        for ifh =1:numel(FH)
            if(contains(FH(ifh).Name,'optical prop','IgnoreCase',true)&&~contains(FH(ifh).Name,'globalview','IgnoreCase',true))
                continue;
            end
            AxH = findobj(FH(ifh),'type','axes');
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
            if(ifh==1), AllData2Write = data2write;
            else, AllData2Write = [AllData2Write;data2write]; end
        end
        if isfile(Name)
            answer = inputdlg('Type different underscore or leave blank to overwrite','File already exist');
            if numel(answer)==0
                delete(RoiObj);
                return
            end
            if ~isempty(answer{1})
                UnderScoreName=answer{1};
                Name = fullfile(Path,[NameHandle.String,UnderScoreName,'.xls']);
            end
        end
        if(isfield(FH(1).UserData,'FitData'))
            Labels = {'Repetition' 'View' 'Breast' 'Session'};
            for ilabs = 1:numel(Labels)
                ActVal=FH(1).UserData.Filters(strcmpi({FH(1).UserData.Filters.Name},Labels{ilabs})).ActualValue;
                if strcmpi(ActVal,'any')
                    ActVal =  FH(1).UserData.FitData.(Labels{ilabs})(1);
                    if isnumeric(ActVal)
                        ActVal = {num2str(ActVal)};
                    end
                end
                if ilabs == 1
                    fitdata = [Labels(ilabs); repmat(ActVal,numel(fieldnames(Roi)),1)];
                else
                    fitdata = [fitdata [Labels(ilabs); repmat(ActVal,numel(fieldnames(Roi)),1)]];
                end
            end
%             fitdata = [[{'View'}; repmat(FH(1).UserData.FitData.View(1),numel(fieldnames(Roi)),1) ] ...
%                 [{'Breast'}; repmat(FH(1).UserData.FitData.Breast(1),numel(fieldnames(Roi)),1) ] ...
%                 [{'Session'}; repmat(num2cell(FH(1).UserData.FitData.Session(1)),numel(fieldnames(Roi)),1) ] ...
%                 [{'Repetition'}; repmat(num2cell(FH(1).UserData.FitData.Repetition(1)),numel(fieldnames(Roi)),1)] ];
        else
            fitdata = [];
        end
        if isprop(ShapeHandle,'Vertices')
            vertdata =  [{'TL X' 'TL Y' 'TR X' 'TR Y' 'BR X' 'BR Y' 'BL X' 'BL Y'};repmat(num2cell(reshape(ShapeHandle.Vertices',1,numel(ShapeHandle.Vertices))),numel(fieldnames(Roi)),1)];
        else
            vertdata = [];
        end
        status=xlswrite(Name,[[{'FileName'}; repmat({NameHandle.String},numel(fieldnames(Roi)),1) ] ...
            fitdata...
            [{'Oper'};fieldnames(Roi)] [AllHeader;struct2cell(AllData2Write)]...
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
                save_figure(FullPath,FigureParent,'-png','-pdf');
                warning on
                msgbox('Figure saved','Success','Help');
            end
        end
        StopWait(ancestor(src,'figure'));
        StopWait(FigureParent);
        delete(RoiObj);
    end
end