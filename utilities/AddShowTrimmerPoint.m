function AddShowTrimmerPoint(parentfigure,object2attach,MFH)
PercFract = 95;
AxH = ancestor(object2attach,'axes');
AxName = AxH.Title.String;
if iscell(AxH.Title.String)
    AxName = AxH.Title.String{1};
end
Tag = ['TP-',parentfigure.Name,'-',AxName];
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
mmh = uimenu(cmh,'Text','Trimmer point');
uimenu(mmh,'Text','Show Trimmer Point','Callback',{@ShowTrimmerPoint});
uimenu(mmh,'Text','Remove Trimmer Point','Callback',{@RemoveTrimmerPoint});


    function ShowTrimmerPoint(~,~)
       [Path,FileName,~]=fileparts(parentfigure.UserData.DataFilePath);
       InfoFilePath = fullfile(Path,[FileName,'_info.txt']);
       if ~isfile(InfoFilePath)
         [FileName,Path,FilterIndex]=uigetfilecustom('*.txt;','Select info file');
         if FilterIndex == 0, return, end
         InfoFilePath = [Path,FileName];
       end
            InfoScan=readtable(InfoFilePath);
            Data = object2attach.CData;
            TrimmCoord = find(Data(1,:)~=0,1,'last')-InfoScan.Var2(contains(InfoScan.Var1,'border'));
            if isempty(TrimmCoord)
               errordlg({['Error reading:' fullfile(Path,[FileName,'_info.txt'])],'No "Border" entry found'},'Error');
               return
            end
            hold on
            plot(AxH,TrimmCoord,1,'Marker','square','MarkerFaceColor','red','MarkerSize',5,'Tag',Tag);
            %text(AxH,TriggCoord,5,num2str(TriggCoord),'FontSize',15);
            hold off
    end
    function RemoveTrimmerPoint(~,~)
       delete(findobj(AxH,'Tag',Tag));
    end
end