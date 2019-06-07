function AddApplyReferenceMask(parentfigure,object2attach,MFH)
PercFract = 95;
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
mmh = uimenu(cmh,'Text','Reference Mask');
uimenu(mmh,'Text','Apply Reference Mask','Callback',{@ApplyReferenceMask});
uimenu(mmh,'Text','Apply To All','Callback',{@CreateLinkDataFigure,'apply'});
uimenu(mmh,'Text','Remove Reference Mask','Callback',{@RemoveReferenceMask});
uimenu(mmh,'Text','Remove From All','Callback',{@CreateLinkDataFigure,'remove'});
    function ApplyReferenceMask(~,~)
        if ~isfield(parentfigure.UserData,'TotalReferenceMask')
            errordlg('no reference mask'); return
        end
        if ~isfield(MFH.UserData,'ReferenceMaskRoi')
            MFH.UserData.ReferenceMaskRoi.ID = 1;
            object2attach.UserData.ReferenceMaskRoi.ID = 1;
        elseif ~isfield(object2attach.UserData,'ReferenceMaskRoi')
            MFH.UserData.ReferenceMaskRoi.ID = ...
                MFH.UserData.ReferenceMaskRoi.ID+1;
            object2attach.UserData.ReferenceMaskRoi.ID = MFH.UserData.ReferenceMaskRoi.ID;
        end
        object2attach.CData = object2attach.CData .* parentfigure.UserData.TotalReferenceMask;
        RoiData = object2attach.CData;
        RoiData(RoiData==0) = NaN;
        Roi.Median = median(RoiData(:),'omitnan');
        Roi.Mean = mean(RoiData(:),'omitnan');
        Roi.Std = std(RoiData(:),'omitnan');
        Roi.CV = Roi.Std./Roi.Mean; Roi.CV(isnan(Roi.CV)) =0;
        Roi.Max = max(RoiData(:));
        Roi.Min = min(RoiData(:));
        Roi.Points = sum(isfinite(RoiData(:)));
        FH=CreateOrFindFig(strcat('Reference Mask Stats - ',num2str(object2attach.UserData.ReferenceMaskRoi.ID)),'NumberTitle','off','ToolBar','none','MenuBar','none');
        if isfield(FH.UserData,'Color')
            FH.Color = FH.UserData.Color;
        else
            FH.Color = rand(1,3);
            FH.UserData.Color = FH.Color;
        end
        rectangle(ancestor(object2attach,'axes'),'Position',[0.5 0.5 object2attach.XData(2) object2attach.YData(2)],'FaceColor','none','EdgeColor',FH.Color,'LineWidth',3);
        FH.UserData.FigCategory = 'ReferenceMaskStats';
        tbh = uitable(FH,'RowName',fieldnames(Roi),'Data',struct2array(Roi)');
        tbh.Position([3 4]) = tbh.Extent([3 4]);
        FH.Position([3 4]) = tbh.Position([3 4]) + [70 40];
        movegui(FH,'southwest')
        FH.Position(2)=FH.Position(2)*5;
        AddToFigureListStruct(FH,MFH,'side');
        %PercVal = GetPercentile(AxH.CData,PercFract);
    end
    function RemoveReferenceMask(~,~)
        if ~isfield(parentfigure.UserData,'TotalReferenceMask')
            errordlg('no reference mask'); return
        end
        AxH=ancestor(object2attach,'axes');
        object2attach.CData = object2attach.UserData.OriginalCData;
        AxH.CLim = AxH.UserData.OriginalCLims;
        delete(findobj(ancestor(object2attach,'axes'),'type','rectangle'));
        %PercVal = GetPercentile(AxH.CData,PercFract);
    end
    function CreateLinkDataFigure(~,~,opertype)
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
        if strcmpi(opertype,'remove')
         OperFunction = @RemoveReferenceMaskFromAll;   
        else
         OperFunction = @ApplyReferenceMaskToAll;   
        end
        CreatePushButton(FH,'Units','Normalized','Position',[0.90 0 0.10 0.08],'String','Link&Run','Callback',{OperFunction,CBH,EH});
        AddToFigureListStruct(FH,MFH,'side');
    end
    function ApplyReferenceMaskToAll(src,~,CheckBoxHandle,NameHandle)
        if ~isfield(parentfigure.UserData,'TotalReferenceMask')
            errordlg('no reference mask'); return
        end
        StartWait(ancestor(src,'figure'));
        actualfhlist = MFH.UserData.AllDataFigs(~contains(MFH.UserData.ListFigures.String,'Select filters'));
        FH=actualfhlist(logical([CheckBoxHandle.Value]));
        FigureParent = parentfigure;
        StartWait(FigureParent);
        UnderScoreName = '_AllMask';
        [Path ,FileName,~] = fileparts(FigureParent.UserData.DataFilePath);
        Name = fullfile(Path,[FileName,UnderScoreName,'.xls']);
        AllData2Write = [];
        AllHeader = [];
        for ifh =1:numel(FH)
            if(contains(FH(ifh).Name,'optical prop','IgnoreCase',true)&&~contains(FH(ifh).Name,'globalview','IgnoreCase',true))
                continue;
            end
            AxH = findobj(FH(ifh),'type','axes');
            clear data2write Header;
            for iaxh = 1:numel(AxH)
                ImH = findobj(AxH(iaxh).Children,'type','image');
                if ~isfield(MFH.UserData,'ReferenceMaskRoi')
                    MFH.UserData.ReferenceMaskRoi.ID = 1;
                    ImH.UserData.ReferenceMaskRoi.ID = 1;
                elseif ~isfield(ImH.UserData,'ReferenceMaskRoi')
                    MFH.UserData.ReferenceMaskRoi.ID = ...
                        MFH.UserData.ReferenceMaskRoi.ID+1;
                    ImH.UserData.ReferenceMaskRoi.ID = MFH.UserData.ReferenceMaskRoi.ID;
                end
                ImH.CData = ImH.CData.* parentfigure.UserData.TotalReferenceMask;
                RoiData = ImH.CData;
                RoiData(RoiData==0) = NaN;
                Roi.Median = median(RoiData(:),'omitnan');
                Roi.Mean = mean(RoiData(:),'omitnan');
                Roi.Std = std(RoiData(:),'omitnan');
                Roi.CV = Roi.Std./Roi.Mean; Roi.CV(isnan(Roi.CV)) =0;
                Roi.Max = max(RoiData(:));
                Roi.Min = min(RoiData(:));
                Roi.Points = sum(isfinite(RoiData(:)));
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
        status=xlswrite(Name,[[{'FileName'}; repmat({NameHandle.String},numel(fieldnames(Roi)),1) ] ...
            fitdata...
            [{'Oper'};fieldnames(Roi)] [AllHeader;struct2cell(AllData2Write)]...
            ]);
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
    end
 function RemoveReferenceMaskFromAll(src,~,CheckBoxHandle,~)
        if ~isfield(parentfigure.UserData,'TotalReferenceMask')
            errordlg('no reference mask'); return
        end
        StartWait(ancestor(src,'figure'));
        actualfhlist = MFH.UserData.AllDataFigs(~contains(MFH.UserData.ListFigures.String,'Select filters'));
        FH=actualfhlist(logical([CheckBoxHandle.Value]));
        FigureParent = parentfigure;
        StartWait(FigureParent);
        
        for ifh =1:numel(FH)
            if(contains(FH(ifh).Name,'optical prop','IgnoreCase',true)&&~contains(FH(ifh).Name,'globalview','IgnoreCase',true))
                continue;
            end
            AxH = findobj(FH(ifh),'type','axes');
            for iaxh = 1:numel(AxH)
                ImH = findobj(AxH(iaxh).Children,'type','image');
                ImH.CData = ImH.UserData.OriginalCData;
                AxH(iaxh).CLim = AxH(iaxh).UserData.OriginalCLims;
            end
        end
        StopWait(ancestor(src,'figure'));
        StopWait(FigureParent);
        close(ancestor(src,'figure'));
    end
end