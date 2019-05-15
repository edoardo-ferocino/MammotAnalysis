function AddSetColorbar(parentfigure,object2attach,MFH)
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
mmh = uimenu(cmh,'Text','Set colorbar','CallBack',{@CreateLinkDataFigure});
%uimenu(mmh,'Text','The same for every image','CallBack',{@SetColorbars});
    
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
        ColLimContH = CreateContainer(FH,'BorderType','line','Units','Normalized','Position',[0.8 0.1 0.3 0.2]);%,'BorderType','none');
%         HighLimH = CreateEdit(ColLimContH,'String',actualnameslist{ifigs},'HorizontalAlignment','Left',...
%                 'Units','Normalized','OuterPosition',[0 0.5 0.3 0.5]);
%         LowLimH = CreateEdit(ColLimContH,'String',actualnameslist{ifigs},'HorizontalAlignment','Left',...
%                 'Units','Normalized','OuterPosition',[0 0 0.3 0.5]);
        AutoSetH = CreateCheckBox(ColLimContH,'String','Auto set','Units','Normalized','Position',[0.8 0.5 0.5 1]);%,'Callback',{@GetColorBarLim,LowLimH,HighLimH});
%         EH=CreateEdit(FH,'String','Linked Name(Type)','HorizontalAlignment','Left',...
%             'Units','Normalized','Position',[0.80 0.08 0.20 0.08]);
        CreatePushButton(FH,'Units','Normalized','Position',[0.90 0 0.10 0.08],'String','Link&Run','Callback',{@SetColorbars,CBH});
        AddToFigureListStruct(FH,MFH,'side');
    end
    function GetColorBarLim(src,~,LowLimH,HighLimH)
      if src.Value ==1, return, end  
        
        
    end
    function SetColorbars(~,~,CheckBoxHandle)
        actualfhlist = MFH.UserData.AllDataFigs(~contains(MFH.UserData.ListFigures.String,'Select filters'));
        FH=actualfhlist(logical([CheckBoxHandle.Value]));
        
        disp('---to do---')
    end

end