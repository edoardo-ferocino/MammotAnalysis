function message = ShowRois(mtoolobj)
mtoolobj(1).Parent.StartWait;
showroimfigobj=mfigure('Name','Show rois','Tag','ShowRoi','FigType','Side','Uifigure','true','Category','ShowRoi');
delete(setdiff(findobj(showroimfigobj.Figure),showroimfigobj.Figure));
AllData = table.empty;AllStyles = matlab.ui.style.Style.empty;
nobjs = numel(mtoolobj);
for iobj = 1:nobjs
    mtoolactvobj = mtoolobj(iobj);
    if isempty(mtoolactvobj.Roi),continue;end
    selectedrois = vertcat(mtoolactvobj.Roi.Selected);
    if sum(selectedrois)==0
        continue;
%         selectedrois = true(1,mtoolactvobj.nRoi);
    end
    styleroi=matlab.ui.style.Style.empty(mtoolactvobj.nRoi,0);
    selectedrois = find(selectedrois);
    for ir = 1:numel(selectedrois)
        styleroi(ir)=uistyle('BackgroundColor',mtoolactvobj.Roi(selectedrois(ir)).Shape.Color);
    end
    Data = struct2table([mtoolactvobj.Roi(selectedrois).RoiValues],'AsArray',true);
    AllData = [AllData;Data]; %#ok<AGROW>
    AllStyles = [AllStyles,styleroi]; %#ok<AGROW>
end
th=uitable(showroimfigobj.Figure,'data',rows2vars(AllData),'Position',[0 0 showroimfigobj.Figure.Position(3) 270+130]); 
th.ColumnWidth = horzcat({100},repelem({100},1,size(th.Data,2))); 
showroimfigobj.Figure.Position(4) = th.Position(4)+20;
uibutton(showroimfigobj.Figure,'Position',[0 th.Position(4) 50 20],'Text','Export','ButtonPushedFcn',{@ExportTable,AllData});
Data = th.Data(1,2:end).Variables;
Data=string(num2str(cell2mat(Data)'));
th.Data.Properties.VariableNames = horzcat('Field',strcat('Roi',Data)');
arrayfun(@(is) addStyle(th,AllStyles(is),'cell',[1 is+1]),1:numel(AllStyles));
message = 'Showed roi';
mtoolobj(1).Parent.StopWait;
end

function ExportTable(~,~,Data)
[FileName,FilePath,FilterIndex]=uiputfilecustom('.xlsx','Save table');
if FilterIndex == 0, return, end
writetable(Data,fullfile(FilePath,FileName),'WriteRowNames',false,'WriteVariableNames',true);
end