function AddPickCurve(parentfigure,object2attach,Data,MFH)
FigureName = ['Pick Curve - ' parentfigure.Name];
CallBackHandle = @PickCurve;
MenuName = 'Pick Curve';
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
uimenu(cmh,'Text',MenuName,'CallBack',{CallBackHandle,parentfigure});


    function PickCurve(src,~,figh)
        if strcmpi(src.Checked,'off')
            src.Checked = 'on';
            src.UserData.originalprops = datacursormode(figh);
        else
            src.Checked = 'off';
        end
        dch = datacursormode(figh);
        dch.removeAllDataCursors;
        if strcmpi(src.Checked,'off')
            dch.DisplayStyle = 'datatip';
            dch.UpdateFcn = [];
            return
        end
        
        datacursormode on
        dch.DisplayStyle = 'window'; ObjMenu = src;
        dch.UpdateFcn = {@PickCurveOnGraph,ObjMenu};
    end
    function output_txt=PickCurveOnGraph(src,~,~)
        AncestorFigure = ancestor(src,'figure');
        pos = src.Position; Xpos = pos(1); Ypos = pos(2);
        FH=CreateOrFindFig(FigureName,false,'NumberTitle','off');
        AddToFigureListStruct(FH,MFH,'side')
        movegui(FH,'southwest')
        [~,~,numbin]=size(Data);
        if isfield(MFH.UserData,'SETT')
           Counts = sum(Data(Ypos,Xpos,:),3); 
           SETT = MFH.UserData.SETT;
           RelCounts = zeros(1,numel(MFH.UserData.Wavelengths)+1);
           RelCounts(1) = (mean(Data(Ypos,Xpos,1:20))*numbin)./Counts*100;
           for iw = 2:numel(MFH.UserData.Wavelengths)+1
            RelCounts(iw) = (sum(Data(Ypos,Xpos,SETT.Roi(iw-1,2)+1:SETT.Roi(iw-1,3)+1),3)-mean(Data(Ypos,Xpos,1:20))*(numel(SETT.Roi(iw-1,2)+1:SETT.Roi(iw-1,3)+1)))./Counts * 100;         
           end
        end
        
        output_txt = {['X: ',num2str(round(Xpos))],...
            ['Y: ',num2str(round(Ypos))],['Countrate: ',num2str(sum(Data(Ypos,Xpos,:))./MFH.UserData.CompiledHeaderData.McaTime)],...
            [char('Bkg',num2str(MFH.UserData.Wavelengths')) num2str(RelCounts',':%.0f%%')]};
        semilogy(1:numbin,squeeze(Data(Ypos,Xpos,:)));
        ylim([10 max(Data(:))]);
        figure(AncestorFigure);
        MinimizeFFS(AncestorFigure);
    end
end