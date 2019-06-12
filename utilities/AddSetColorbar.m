function AddSetColorbar(parentfigure,object2attach,MFH)
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
mmh = uimenu(cmh,'Text','Colorbar');
uimenu(mmh,'Text','Change this colorbar','CallBack',{@ChangeThisColorbar});
uimenu(mmh,'Text','Restore this colorbar','CallBack',{@RestoreThisColorbar});
uimenu(mmh,'Text','Link colorbars','CallBack',{@CreateLinkDataFigure});

    function CreateLinkDataFigure(~,~)
        [FH,CH,CBH]=CreateLinkDataFigGen(MFH);
        ColLimContH = CreateContainer(FH,'BorderType','line','Units','Normalized','Position',[0.75 0.1 0.2 0.2]);%,'BorderType','none');
        HighLimH = CreateEdit(ColLimContH,'String','High lim','HorizontalAlignment','Left',...
            'Units','Normalized','OuterPosition',[0 0.5 1 0.5]);
        LowLimH = CreateEdit(ColLimContH,'String','Low lim','HorizontalAlignment','Left',...
            'Units','Normalized','OuterPosition',[0 0 1 0.5]);
        AutoSetH = CreateCheckBox(FH,'Value',true,'Units','Normalized','String','Auto set','Position',[0.75 0.30 0.2 0.08],'Callback',{@GetMaxMinColorBarLim,CBH,LowLimH,HighLimH});
        CreatePushButton(FH,'Units','Normalized','String','Restore Checked Colorbars','Position',[0.70 0.4 0.25 0.08],'Callback',{@RestoreAllColorbars,CBH});
        
        CreatePushButton(FH,'Units','Normalized','Position',[0.85 0 0.10 0.08],'String','Link&Run','Callback',{@SetAllColorbars,CBH,LowLimH,HighLimH,AutoSetH});
        AddToFigureListStruct(FH,MFH,'side');
    end
    function GetMaxMinColorBarLim(src,~,CheckBoxHandle,LowLimH,HighLimH)
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
    function SetAllColorbars(~,~,CheckBoxHandle,LowLimH,HighLimH,AutoSetH)
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
    function RestoreThisColorbar(src,~)
        AxH=ancestor(object2attach,'axes');
        CBToolFigH = ancestor(src,'figure');
        AxH.CLim = AxH.UserData.OriginalCLims;
        Objs = findobj(CBToolFigH,'Tag','LowLimCB');
        Objs.String = num2str(AxH.CLim(1));
        Objs = findobj(CBToolFigH,'Tag','HighLimCB');
        Objs.String = num2str(AxH.CLim(2));
    end
    function RestoreAllColorbars(~,~,CheckBoxHandle)
        actualfhlist = MFH.UserData.AllDataFigs(~contains(MFH.UserData.ListFigures.String,'Select filters'));
        FH=actualfhlist(logical([CheckBoxHandle.Value]));
        for ifigs = 1:numel(FH)
            AxH=findobj(FH(ifigs),'type','axes');
            for iaxh = 1:numel(AxH)
                AxH(iaxh).CLim = AxH(iaxh).UserData.OriginalCLims;
            end
        end
    end
    function ChangeThisColorbar(~,~)
        AxH=ancestor(object2attach,'axes');
        Tag = ['CB-',parentfigure.Name,'-',AxH.Title.String];
        FH=CreateOrFindFig(['CB-',AxH.Title.String],'Tag',Tag,'numbertitle','off','MenuBar','none','toolbar','none','units','normalized');
        FH.Position = AxH.Position + [AxH.Position(3)/3 0 -0.1*AxH.Position(3) -0.8*AxH.Position(4)];
        FH.UserData.FigCategory = 'ChangeColorbar';
        CreateEdit(FH,'units','normalized','String','High','String',num2str(AxH.CLim(2)),'Callback',{@SetColorBar,AxH,'high'},'Position',[0 0.5 0.3 0.5],'Tag','HighLimCB');
        CreateEdit(FH,'units','normalized','String','Low','String',num2str(AxH.CLim(1)),'Callback',{@SetColorBar,AxH,'low'},'Position',[0 0 0.3 0.5],'Tag','LowLimCB');
        CreateText(FH,'units','normalized','String','High','Position',[0.3 0.3 0.3 0.5]);
        CreateText(FH,'units','normalized','String','Low','Position',[0.3 0 0.3 0.5]);
        CreatePushButton(FH,'units','normalized','String','Restore','Position',[0.6 0.25 0.4 0.5],'Callback',{@RestoreThisColorbar});
        AddToFigureListStruct(FH,MFH,'side');
        function SetColorBar(src,~,AxH,type)
           ValPos = 2; 
           if strcmpi(type,'low')
              ValPos = 1;
           end
           AxH.CLim(ValPos) =  str2double(src.String);
        end
    end

end