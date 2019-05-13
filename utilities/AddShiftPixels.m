function AddShiftPixels(parentfigure,object2attach,MFH)
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
uimenu(cmh,'Text','Correct shift','Callback',@CreateShiftCorrectFigure);

    function CreateShiftCorrectFigure(~,~)
        AxH=ancestor(object2attach,'axes');
        Tag = [parentfigure.Name,'-',AxH.Title.String];
        FH=CreateOrFindFig('Correct shift tool',false,'NumberTitle','off','Toolbar','none','Menubar','none','Units','Normalized','Position',[0.5 0.5 0.2 0.2],'Tag','n');
        ch = CreateContainer(FH,'Units','Normalized','Position',[0 0 1 1],'Visible','on');
        bg = uibuttongroup(FH,'Visible','on','Position',[0 0 0.3 1]);
        CreateRadioButton(bg,'String','Shift even rows','units','normalized','position',[0 0 1 0.5],'Tag','even');
        CreateRadioButton(bg,'String','Shift odd rows','units','normalized','position',[0 0.5 1 0.5],'Tag','odd');
        %CreateRadioButton(ch,'String','Dir pos','units','normalized','position',[0.4 0 0.4 0.5],'Tag','dirpos');
        %CreateRadioButton(ch,'String','Dir neg','units','normalized','position',[0.4 0.5 0.4 0.5],'Tag','dirneg');
        CreateEdit(ch,'units','normalized','position',[0.4 0.2 0.1 0.1],'Tag','quantity');
        CreateText(ch,'String','Quantity','units','normalized','position',[0.35 0.3 0.2 0.1]);
        CreateEdit(ch,'units','normalized','position',[0.8 0.2 0.1 0.1],'Tag','absoluteshift');
        CreateText(ch,'String','Absolute shift','units','normalized','position',[0.75 0.4 0.2 0.15]);
        CreatePushButton(ch,'units','normalized','String','Apply','Position',[0.4 0.8 0.1 0.2],'Callback',{@ApplyShiftCorrection,ch,bg});
        CreatePushButton(ch,'units','normalized','String','Apply to data','Position',[0.7 0.8 0.3 0.2],'Callback',{@CreateLinkDataFigure});
        CreatePushButton(ch,'units','normalized','String','Restore','Position',[0.7 0.6 0.3 0.2],'Callback',{@Restore});
        CreateText(ch,'String',Tag,'units','normalized','position',[0.3 0 0.7 0.15]);
        AddToFigureListStruct(FH,MFH,'side');
    end
    function CreateLinkDataFigure(~,~)
        FH = CreateOrFindFig('Link Figures',false,'NumberTitle','off','Toolbar','None','MenuBar','none');
        clf(FH);
        actualnameslist = MFH.UserData.ListFigures.String(~contains(MFH.UserData.ListFigures.String,'Select filters'));
        numfig = numel(actualnameslist);
        contains(MFH.UserData.ListFigures.String,'Select filters');
        for ifigs = 1:numfig
            CH(ifigs) = CreateContainer(FH,'BorderType','none','Units','Normalized','Position',[0 (1/numfig)*(ifigs-1) 1 1/numfig]);%,'BorderType','none');
            CreateEdit(CH(ifigs),'String',actualnameslist{ifigs},'HorizontalAlignment','Left',...
                'Units','Normalized','OuterPosition',[0 0 0.7 1]);
            CBH(ifigs) = CreateCheckBox(CH(ifigs),'String','Link','Units','Normalized','Position',[0.7 0 0.1 1]);
        end
        %         EH=CreateEdit(FH,'String','Linked Name(Type)','HorizontalAlignment','Left',...
        %                 'Units','Normalized','Position',[0.80 0.08 0.20 0.08]);
        CreatePushButton(FH,'Units','Normalized','Position',[0.90 0 0.10 0.08],'String','Link&Run','Callback',{@ApplyToData,CBH});
        AddToFigureListStruct(FH,MFH,'side');
    end
    function ApplyShiftCorrection(~,~,ch,bg)
        QuantH = findobj(ch,'Tag','quantity');
        EvenH = findobj(bg,'Tag','even');
        OddH = findobj(bg,'Tag','odd');
        if(contains(bg.SelectedObject.String,'even'))
            iseven = true;
        else
            iseven = false;
        end
        if ~isfield(object2attach.UserData,'ShiftOriginalData')
            object2attach.UserData.ShiftOriginalData = object2attach.CData;
        end
        Data = object2attach.CData;
        if strcmpi(MFH.UserData.ProfileOrientation,'horizontal')
            Coord = size(Data,1);
        else
            Coord = size(Data,2);
        end
        Coord = 1:Coord;
        if(~isfield(EvenH.UserData,'Val'))
            EvenH.UserData.Val = 0;
        end
        if(~isfield(OddH.UserData,'Val'))
            OddH.UserData.Val = 0;
        end
        if iseven
            Coord = Coord(rem(Coord,2)==1);
            MFH.UserData.ShiftDimType = 'even';
            EvenH.UserData.Val = EvenH.UserData.Val+str2double(QuantH.String);
        else
            Coord = Coord(rem(Coord,2)==0);
            MFH.UserData.ShiftDimType = 'odd';
            OddH.UserData.Val = OddH.UserData.Val+str2double(QuantH.String);
        end
        MFH.UserData.ShiftDimIndxs = Coord;
        
        if strcmpi(MFH.UserData.ProfileOrientation,'horizontal')
            Data(Coord,:) = circshift(Data(Coord,:),str2double(QuantH.String),2);
        else
            Data(:,Coord) = circshift(Data(:,Coord),str2double(QuantH.String),1);
        end
        AbsShift = findobj(ch,'tag','absoluteshift');
        if isempty(AbsShift.String)
            AbsShift.String = num2str(0);
        end
        AbsShift.String = num2str(EvenH.UserData.Val-OddH.UserData.Val);%num2str(str2double(AbsShift.String)+str2double(QuantH.String));
        object2attach.CData = Data;
        MFH.UserData.ShiftDimVal = str2double(AbsShift.String);
    end
    function ApplyToData(~,~,CheckBoxHandle)
        actualfhlist = MFH.UserData.AllDataFigs(~contains(MFH.UserData.ListFigures.String,'Select filters'));
        FHList=actualfhlist(logical([CheckBoxHandle.Value]));
        for ifigs=1:numel(FHList)
            FigureParent = FHList(ifigs);
            StartWait(FigureParent);
            FH = copyobj(FigureParent,groot,'legacy');
            newName = FH.Name;
            while ~isempty(findobj('name',newName,'type','figure'))
                newName = [newName '-Shifted'];  %#ok<AGROW>
            end
            FH.Name = newName;
            StopWait(FigureParent);
            StopWait(FH);
            %Restore();
            imh = findobj(FH,'type','image');
            for ih = 1:numel(imh)
                if isfield(MFH.UserData,'rows')
                    AddGetTableInfo(FH,imh(ih),FH.UserData.Filters,FH.UserData.rows,FH.UserData.FitData)
                end
            end
            if isfield(FH.UserData,'InfoData')
                AddInfoEntry(MFH,MFH.UserData.ListFigures,FH,MFH);
            end
            AddToFigureListStruct(FH,MFH,'data',FH.UserData.DataFilePath);
        end
        msh = msgbox({'Shift applied' 'The new figure will be listed in the list box'},'Success','help');
        movegui(msh,'center');
        waitfor(msh);
        answer = questdlg('Use the shifted data for analysis?','Shifted data','Yes','No','No');
        if strcmpi(answer,'yes')
            msh = msgbox('Please run again the analysis','Success','help');
            movegui(msh,'center');
            waitfor(msh);
            MFH.UserData.ApplyShift = true;
        end
    end
    function Restore(~,~,FH)
        clf(FH);
        CreateShiftCorrectFigure
        if isfield(object2attach.UserData,'ShiftOriginalData')
            object2attach.CData = object2attach.UserData.ShiftOriginalData;
            object2attach.UserData = rmfield(object2attach.UserData,'ShiftOriginalData');
        end
    end
end