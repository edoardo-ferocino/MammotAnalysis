function AddShiftPixels(parentfigure,object2attach,MFH)
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
uimenu(cmh,'Text','Correct shift','Callback',{@CreateShiftCorrectFigure,false});

    function FH=CreateShiftCorrectFigure(~,~,isnew)
        AxH=ancestor(object2attach,'axes');
        Tag = [parentfigure.Name,'-',AxH.Title.String,'-',num2str(parentfigure.Number)];
        if(isempty(findobj(groot,'Tag',Tag))||isnew)
            if isnew
                clf(findobj(groot,'Tag',Tag'))
            end
            FH=CreateOrFindFig('Correct shift tool',false,'NumberTitle','off','Toolbar','none','Menubar','none','Units','Normalized','Position',[0.5 0.5 0.2 0.2],'Tag',Tag);
            ch = CreateContainer(FH,'Units','Normalized','Position',[0 0 1 1],'Visible','on');
            bg = uibuttongroup(FH,'Visible','on','Position',[0 0 0.3 1],'Tag','EvenOrOdd');
            CreateRadioButton(bg,'String','Shift even rows','units','normalized','position',[0 0 1 0.5],'Tag','even');
            CreateRadioButton(bg,'String','Shift odd rows','units','normalized','position',[0 0.5 1 0.5],'Tag','odd');
            CreateEdit(ch,'units','normalized','position',[0.4 0.2 0.1 0.1],'Tag','quantity');
            CreateText(ch,'String','Quantity','units','normalized','position',[0.35 0.3 0.2 0.1]);
            CreateEdit(ch,'units','normalized','position',[0.8 0.2 0.1 0.1],'Tag','relshift');
            CreateText(ch,'String','Relative shift','units','normalized','position',[0.75 0.4 0.2 0.15]);
            CreatePushButton(ch,'units','normalized','String','Apply','Position',[0.4 0.8 0.1 0.2],'Callback',{@ApplyShiftCorrection});
            CreatePushButton(ch,'units','normalized','String','Apply to data','Position',[0.7 0.8 0.3 0.2],'Callback',{@CreateLinkDataFigure});
            CreatePushButton(ch,'units','normalized','String','Restore','Position',[0.7 0.6 0.3 0.2],'Callback',{@Restore});
            CreateText(ch,'String',Tag,'units','normalized','position',[0.3 0 0.7 0.15]);
        else
            FH=CreateOrFindFig('Correct shift tool',false,'NumberTitle','off','Toolbar','none','Menubar','none','Units','Normalized','Position',[0.5 0.5 0.2 0.2],'Tag',Tag);
        end
        object2attach.UserData.ShiftToolH = FH;
        FH.CloseRequestFcn = {@SetFigureInvisible,FH};
        AddToFigureListStruct(FH,MFH,'side');
    end
    function CreateLinkDataFigure(~,~)
        FH = CreateOrFindFig('Link Figures',false,'NumberTitle','off','Toolbar','None','MenuBar','none');
        clf(FH);
        actualnameslist = MFH.UserData.ListFigures.String(~contains(MFH.UserData.ListFigures.String,'Select filters'));
        numfig = numel(actualnameslist);
        for ifigs = 1:numfig
            CH(ifigs) = CreateContainer(FH,'BorderType','none','Units','Normalized','Position',[0 (1/numfig)*(ifigs-1) 1 1/numfig]);%,'BorderType','none');
            CreateEdit(CH(ifigs),'String',actualnameslist{ifigs},'HorizontalAlignment','Left',...
                'Units','Normalized','OuterPosition',[0 0 0.7 1]);
            CBH(ifigs) = CreateCheckBox(CH(ifigs),'String','Link','Units','Normalized','Position',[0.7 0 0.1 1]);
        end
        CreatePushButton(FH,'Units','Normalized','Position',[0.90 0 0.10 0.08],'String','Link&Run','Callback',{@ApplyToData,CBH});
        AddToFigureListStruct(FH,MFH,'side');
    end
    function ApplyShiftCorrection(src,~)
        QuantH = findobj(ancestor(src,'figure'),'Tag','quantity');
        EvenH = findobj(ancestor(src,'figure'),'Tag','even');
        OddH = findobj(ancestor(src,'figure'),'Tag','odd');
        bg = findobj(ancestor(src,'figure'),'Tag','EvenOrOdd');
        RelShift = findobj(ancestor(src,'figure'),'tag','relshift');
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
            EvenH.UserData.Val = EvenH.UserData.Val+str2double(QuantH.String);
        else
            Coord = Coord(rem(Coord,2)==0);
            OddH.UserData.Val = OddH.UserData.Val+str2double(QuantH.String);
        end
        
        if strcmpi(MFH.UserData.ProfileOrientation,'horizontal')
            Data(Coord,:) = circshift(Data(Coord,:),str2double(QuantH.String),2);
        else
            Data(:,Coord) = circshift(Data(:,Coord),str2double(QuantH.String),1);
        end
        
        if isempty(RelShift.String)
            RelShift.String = num2str(0);
        end
        RelShift.String = num2str(EvenH.UserData.Val-OddH.UserData.Val);%num2str(str2double(AbsShift.String)+str2double(QuantH.String));
        object2attach.CData = Data;
    end
    function ApplyToData(~,~,CheckBoxHandle)
        FigShiftH = object2attach.UserData.ShiftToolH;
        EvenH = findobj(FigShiftH,'Tag','even');
        EvenVal = EvenH.UserData.Val;
        OddH = findobj(FigShiftH,'Tag','odd');
        OddVal = OddH.UserData.Val;
        
        actualfhlist = MFH.UserData.AllDataFigs(~contains(MFH.UserData.ListFigures.String,'Select filters'));
        FHList=actualfhlist(logical([CheckBoxHandle.Value]));
        for ifigs=1:numel(FHList)
            FigureParent = FHList(ifigs);
            StartWait(FigureParent);
            Restore();
            FH = copyobj(FigureParent,groot,'legacy');
            newName = FH.Name;
            while ~isempty(findobj('name',newName,'type','figure'))
                newName = [newName '-Shifted'];  %#ok<AGROW>
            end
            FH.Name = newName;
            ImH = findobj(FH,'type','image');
            for imh = 1:numel(ImH)
                Data = ImH(imh).CData;
                if strcmpi(MFH.UserData.ProfileOrientation,'horizontal')
                    Coord = size(Data,1);
                else
                    Coord = size(Data,2);
                end
                Coord = 1:Coord;
                CoordEven = Coord(rem(Coord,2)==1);
                CoordOdd = Coord(rem(Coord,2)==0);
                if strcmpi(MFH.UserData.ProfileOrientation,'horizontal')
                    Data(CoordEven,:) = circshift(Data(CoordEven,:),EvenVal,2);
                    Data(CoordOdd,:) = circshift(Data(CoordOdd,:),OddVal,2);
                else
                    Data(:,CoordEven) = circshift(Data(:,CoordEven),EvenVal,1);
                    Data(:,CoordOdd) = circshift(Data(:,CoordOdd),OddVal,1);
                end
                ImH(imh).CData = Data;
            end
            if(isfield(FH.UserData,'DatData'))
                Size=size(FH.UserData.DatData);
                FH.UserData.DatData(CoordEven,:) =...
                    circshift(FH.UserData.DatData(CoordEven,:),EvenVal,2);
                FH.UserData.DatData(CoordOdd,:) =...
                    circshift(FH.UserData.DatData(CoordOdd,:),OddVal,2);
                FH.UserData.DatData=reshape(FH.UserData.DatData,Size);
            end
            StopWait(FigureParent);
            StopWait(FH);
            AddToFigureListStruct(FH,MFH,'data',FH.UserData.DataFilePath);
        end
        msh = msgbox({'Shift applied' 'The new figure will be listed in the list box'},'Success','help');
        movegui(msh,'center');
        waitfor(msh);
    end
    function Restore(~,~)
        CreateShiftCorrectFigure([],[],true);
        if isfield(object2attach.UserData,'ShiftOriginalData')
            object2attach.CData = object2attach.UserData.ShiftOriginalData;
            object2attach.UserData = rmfield(object2attach.UserData,'ShiftOriginalData');
        end
    end
end