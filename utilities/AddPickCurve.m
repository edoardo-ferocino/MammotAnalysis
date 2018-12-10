function AddPickCurve(parentfigure,object2attach,Data,MFH)
[~,FileName,~] = fileparts(MFH.UserData.DispDatFilePath.String);
FigureName = ['Pick Curve - ' FileName];
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
        FH = findobj('Type','figure','-and','Name',FigureName);
        if ~isempty(FH)
            figure(FH);
        else
            FH=figure('NumberTitle','off','Name',FigureName);
        end
        AddToFigureListStruct(FH,MFH,'side')
        movegui(FH,'southwest')
        if isfield(MFH.UserData,'SETT')
           Counts = sum(Data(Ypos,Xpos,:),3); 
           SETT = MFH.UserData.SETT;
           for iw = 1:numel(MFH.UserData.Wavelengths)
            RelCounts(iw) = sum(Data(Ypos,Xpos,SETT.Roi(iw,2)+1:SETT.Roi(iw,3)+1),3)./Counts * 100;         
           end
        end
        %realhandle = findobj(ancestor(src,'axes'),'type','image');
        [~,~,numbin]=size(Data);
        output_txt = {['X: ',num2str(round(Xpos))],...
            ['Y: ',num2str(round(Ypos))],['Z: ',num2str(sum(Data(Ypos,Xpos,:))./MFH.UserData.CompiledHeaderData.McaTime)],...
            [num2str(MFH.UserData.Wavelengths') num2str(RelCounts',':%.0f%%')]};
        semilogy(1:numbin,squeeze(Data(Ypos,Xpos,:)));
        ylim([10 max(Data(:))]);
        figure(AncestorFigure);
        MinimizeFFS(AncestorFigure);
    end
end