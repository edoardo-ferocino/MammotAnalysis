function AddShiftPixels(parentfigure,object2attach,MFH)
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
uimenu(cmh,'Text','Correct shift','Callback',@CreateShiftCorrectFigure);

    function CreateShiftCorrectFigure(~,~)
        FH = findobj('Type','figure','-and','Name','Correct shift tool');
        if ~isempty(FH)
            figure(FH);
        else
            FH=figure('NumberTitle','off','Toolbar','none','Menubar','none','Name','Correct shift tool','Units','Normalized','Position',[0.5 0.5 0.2 0.2]);
        end
        ch = CreateContainer(FH,'Units','Normalized','Position',[0 0 1 1]);
        CreateRadioButton(ch,'String','Shift even rows','units','normalized','position',[0 0 0.4 0.5],'Tag','even'...
            ,'Callback','obj = findobj(ancestor(gcbo,''uipanel''),''Tag'',''odd'');obj.Value = 0;');
        CreateRadioButton(ch,'String','Shift odd rows','units','normalized','position',[0 0.5 0.4 0.5],'Tag','odd'...
            ,'Callback','obj = findobj(ancestor(gcbo,''uipanel''),''Tag'',''even'');obj.Value = 0;');
        %CreateRadioButton(ch,'String','Dir pos','units','normalized','position',[0.4 0 0.4 0.5],'Tag','dirpos');
        %CreateRadioButton(ch,'String','Dir neg','units','normalized','position',[0.4 0.5 0.4 0.5],'Tag','dirneg');
        CreateEdit(ch,'units','normalized','position',[0.4 0.2 0.1 0.1],'Tag','quantity');
        CreateText(ch,'String','Quantity','units','normalized','position',[0.35 0.3 0.2 0.1]);
        CreateEdit(ch,'units','normalized','position',[0.8 0.2 0.1 0.1],'Tag','absoluteshift');
        CreateText(ch,'String','Absolute shift','units','normalized','position',[0.75 0.4 0.2 0.15]);
        CreatePushButton(ch,'units','normalized','String','Apply','Position',[0.4 0.8 0.1 0.2],'Callback',{@ApplyShiftCorrection,ch});
        CreatePushButton(ch,'units','normalized','String','Apply to data','Position',[0.7 0.8 0.3 0.2],'Callback',{@ApplyToData});
        CreatePushButton(ch,'units','normalized','String','Restore','Position',[0.7 0.6 0.3 0.2],'Callback',{@Restore});
    end
    function ApplyShiftCorrection(~,~,ch)
        EvenH = findobj(ch,'Tag','even');
        OddH = findobj(ch,'Tag','odd');
        QuantH = findobj(ch,'Tag','quantity');
        
        if EvenH.Value
            iseven = true;
        else
            iseven = false;
        end
        if ~isfield(MFH.UserData,'ShiftOriginalData')
            MFH.UserData.ShiftOriginalData = object2attach.CData;
            MFH.UserData.ShiftDataObject = object2attach;
            OddH.UserData.Val = 0;
            EvenH.UserData.Val = 0;
            
        end
        Data = object2attach.CData;
        if strcmpi(MFH.UserData.ProfileOrientation,'horizontal')
            Coord = size(Data,1);
        else
            Coord = size(Data,2);
        end
        Coord = 1:Coord;
        
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
    function ApplyToData(src,~)
        close(ancestor(src,'figure'));
        FigureParent = parentfigure;
        StartWait(FigureParent);
        FH = copyobj(FigureParent,groot,'legacy');
        newName = FH.Name;
        while ~isempty(findobj('name',newName,'type','figure'))
            newName = [newName '-Shifted'];  %#ok<AGROW>
        end
        FH.Name = newName;
        StopWait(FigureParent);
        StopWait(FH);
        Restore();
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
        AddToFigureListStruct(FH,MFH,'data')
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
    function Restore(~,~)
        MFH.UserData.ShiftDataObject.CData = MFH.UserData.ShiftOriginalData;
        MFH.UserData = rmfield(MFH.UserData,'ShiftDataObject');
        MFH.UserData = rmfield(MFH.UserData,'ShiftOriginalData');
    end
end