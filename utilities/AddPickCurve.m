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
        FH=CreateOrFindFig(FigureName,'NumberTitle','off');
        FH.UserData.FigCategory = 'PickCurve';
        movegui(FH,'southwest')
        [~,~,numbin]=size(Data);
        semilogy(1:numbin,squeeze(Data(Ypos,Xpos,:)));
        xlim([1 numbin]);
        ylim([10 max(Data(:))]);
        if isfield(parentfigure.UserData,'TrsSet')
           Counts = sum(Data(Ypos,Xpos,:),3); 
           SETT = parentfigure.UserData.TrsSet;
           RelCounts = zeros(1,numel(MFH.UserData.Wavelengths)+1);
           RelCounts(1) = (mean(Data(Ypos,Xpos,1:20))*numbin)./Counts*100;
           for iw = 2:numel(MFH.UserData.Wavelengths)+1
            RelCounts(iw) = (sum(Data(Ypos,Xpos,SETT.Roi(iw-1,2)+1:SETT.Roi(iw-1,3)+1),3)-mean(Data(Ypos,Xpos,1:20))*(numel(SETT.Roi(iw-1,2)+1:SETT.Roi(iw-1,3)+1)))./Counts * 100;         
            [CurveWidth(iw),CurveBar(iw)]=CalcWidth(Data(Ypos,Xpos,SETT.Roi(iw-1,2)+1:SETT.Roi(iw-1,3)+1),0.5);
            vline(SETT.Roi(iw-1,3)+1,'r','');
           end
        end
       CurveWidth = CurveWidth.*parentfigure.UserData.CompiledHeaderData.McaFactor;
        output_txt = [...
            {strcat('X: ',num2str(round(Xpos)))},...
            {strcat('Y: ',num2str(round(Ypos)))},...
            {strcat('Countrate: ',num2str(sum(Data(Ypos,Xpos,:))./parentfigure.UserData.CompiledHeaderData.McaTime))},...
            {strcat(char('Bkg',num2str(MFH.UserData.Wavelengths')),num2str(RelCounts',':%.0f%%, '),num2str(RelCounts'./100*Counts,'BkgFree: %g, '),num2str(CurveWidth','width: %.0f ps, '),num2str(CurveBar','Bar: %.1f ch'))}];
        AddToFigureListStruct(FH,MFH,'side')
        figure(AncestorFigure);
        MinimizeFFS(AncestorFigure);
    end
end