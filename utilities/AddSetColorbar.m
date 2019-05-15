function AddSetColorbar(parentfigure,object2attach,MFH)
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
mmh = uimenu(cmh,'Text','Colorbar');
uimenu(mmh,'Text','Set colorbar','CallBack',{@CreateLinkDataFigure});
uimenu(mmh,'Text','Restore colorbar','CallBack',{@RestoreColorbar});

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
            if strcmpi(actualnameslist{ifigs}(1:strfind(actualnameslist{ifigs},'-')-1)...
                    ,parentfigure.Name((1:strfind(actualnameslist{ifigs},'-')-1)))
                CBH(ifigs).Value = true;
            end
        end
        ColLimContH = CreateContainer(FH,'BorderType','line','Units','Normalized','Position',[0.8 0.1 0.2 0.2]);%,'BorderType','none');
        HighLimH = CreateEdit(ColLimContH,'String','High lim','HorizontalAlignment','Left',...
            'Units','Normalized','OuterPosition',[0 0.5 1 0.5]);
        LowLimH = CreateEdit(ColLimContH,'String','Low lim','HorizontalAlignment','Left',...
            'Units','Normalized','OuterPosition',[0 0 1 0.5]);
        AutoSetH = CreateCheckBox(FH,'Value',true,'Units','Normalized','String','Auto set','Position',[0.8 0.30 0.2 0.08],'Callback',{@GetColorBarLim,CBH,LowLimH,HighLimH});
        RestoreAllH = CreateCheckBox(FH,'Value',false,'Units','Normalized','String','Restore','Position',[0.8 0.4 0.2 0.08],'Callback',{@RestoreAll,CBH});
        
        CreatePushButton(FH,'Units','Normalized','Position',[0.90 0 0.10 0.08],'String','Link&Run','Callback',{@SetColorbars,CBH,LowLimH,HighLimH,AutoSetH});
        AddToFigureListStruct(FH,MFH,'side');
    end
    function GetColorBarLim(src,~,CheckBoxHandle,LowLimH,HighLimH)
        if src.Value ==1, return, end
        actualfhlist = MFH.UserData.AllDataFigs(~contains(MFH.UserData.ListFigures.String,'Select filters'));
        FH=actualfhlist(logical([CheckBoxHandle.Value]));
        RefAxH=ancestor(object2attach,'axes');
        RefLims = RefAxH.CLim;
        minval = inf; maxval = 0;
        for ifigs = 1:numel(FH)
            AxH=findobj(FH(ifigs),'type','axes');
            for iaxh = 1:numel(AxH)
                if(strcmpi(AxH(iaxh).Title.String,RefAxH.Title.String))
                    minval = min([minval;AxH(iaxh).CLim(1); RefLims(1)],[],1);
                    maxval = max([maxval; AxH(iaxh).CLim(2); RefLims(2)],[],1);
                end
            end
        end
        LowLimH.String = num2str(minval);
        HighLimH.String = num2str(maxval);
    end
    function SetColorbars(~,~,CheckBoxHandle,LowLimH,HighLimH,AutoSetH)
        actualfhlist = MFH.UserData.AllDataFigs(~contains(MFH.UserData.ListFigures.String,'Select filters'));
        FH=actualfhlist(logical([CheckBoxHandle.Value]));
        RefAxH=ancestor(object2attach,'axes');
        RefLims = RefAxH.CLim;
        minval = inf; maxval = 0;
        for ifigs = 1:numel(FH)
            AxH=findobj(FH(ifigs),'type','axes');
            for iaxh = 1:numel(AxH)
                if(strcmpi(AxH(iaxh).Title.String,RefAxH.Title.String))
                    minval = min([minval;AxH(iaxh).CLim(1); RefLims(1)],[],1);
                    maxval = max([maxval; AxH(iaxh).CLim(2); RefLims(2)],[],1);
                end
            end
        end
        for ifigs = 1:numel(FH)
            AxH=findobj(FH(ifigs),'type','axes');
            for iaxh = 1:numel(AxH)
                if(strcmpi(AxH(iaxh).Title.String,RefAxH.Title.String))
                    if AutoSetH.Value
                        AxH(iaxh).CLim = [minval maxval];
                    else
                        AxH(iaxh).CLim = [str2double(LowLimH.String) str2double(HighLimH.String) ];
                    end
                end
            end
        end
    end
    function RestoreColorbar(~,~)
        AxH=ancestor(object2attach,'axes');
        AxH.CLim = AxH.UserData.OriginalCLims;
    end
    function RestoreAll(src,~,CheckBoxHandle)
        if src.Value == 0, return, end
        actualfhlist = MFH.UserData.AllDataFigs(~contains(MFH.UserData.ListFigures.String,'Select filters'));
        FH=actualfhlist(logical([CheckBoxHandle.Value]));
        for ifigs = 1:numel(FH)
            AxH=findobj(FH(ifigs),'type','axes');
            for iaxh = 1:numel(AxH)
                AxH(iaxh).CLim = AxH(iaxh).UserData.OriginalCLims;
            end
        end
    end

end