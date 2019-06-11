function AddShowTrimmerPoint(parentfigure,object2attach,MFH)
PercFract = 95;
AxH = ancestor(object2attach,'axes');
Tag = ['TP-',parentfigure.Name,'-',AxH.Title.String];
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
[Path,FileName,~]=fileparts(parentfigure.UserData.DataFilePath);
mmh = uimenu(cmh,'Text','Trimmer point');
uimenu(mmh,'Text','Show Trimmer Point','Callback',{@ShowTrimmerPoint});
uimenu(mmh,'Text','Remove Trimmer Point','Callback',{@RemoveTrimmerPoint});


    function ShowTrimmerPoint(~,~)
       if isfile(fullfile(Path,[FileName,'_info.txt']))
            InfoScan=readtable(fullfile(Path,[FileName,'_info.txt']));
            Data = object2attach.CData;
            TriggCoord = find(Data(1,:)~=0,1,'last')-InfoScan.Var2(contains(InfoScan.Var1,'border'));
            if isempty(TrigCoord)
               errordlg({['Error reading:' fullfile(Path,[FileName,'_info.txt'])],'No "Border" entry found'},'Error');
               return
            end
            hold on
            plot(AxH,TriggCoord,1,'Marker','square','MarkerFaceColor','red','MarkerSize',5,'Tag',Tag);
            %text(AxH,TriggCoord,5,num2str(TriggCoord),'FontSize',15);
            hold off
        end 
    end
    function RemoveTrimmerPoint(~,~)
       delete(findobj(AxH,'Tag',Tag));
    end
end