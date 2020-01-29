function message = ShowRois(mtoolobj)
mtoolobj.Parent.StartWait;
showroimfigobj=mfigure('Name','Show rois','Tag','ShowRoi','FigType','Side','Uifigure','true','Category','ShowRoi');
delete(setdiff(findobj(showroimfigobj.Figure),showroimfigobj.Figure));
AllData = [];AllStyles = [];
nobjs = numel(mtoolobj);
for iobj = 1:nobjs
    mtoolactvobj = mtoolobj(iobj);
    if isempty(mtoolactvobj.Roi),continue;end
    selectedrois = vertcat(mtoolactvobj.Roi.Selected);
    if sum(selectedrois)==0, selectedrois = true(1,mtoolactvobj.nRoi); end
    styleroi=matlab.ui.style.Style.empty(mtoolactvobj.nRoi,0);
    selectedrois = find(selectedrois);
    for ir = 1:numel(selectedrois)
        styleroi(ir)=uistyle('BackgroundColor',mtoolactvobj.Roi(selectedrois(ir)).Shape.Color);
    end
    Data = struct2table([mtoolactvobj.Roi(selectedrois).RoiValues],'AsArray',true);
    AllData = [AllData;Data]; %#ok<AGROW>
    AllStyles = [AllStyles,styleroi]; %#ok<AGROW>
end
th=uitable(showroimfigobj.Figure,'data',rows2vars(AllData));
th.Position(3) = showroimfigobj.Figure.Position(3)*6/7;
th.Position(4) = showroimfigobj.Figure.Position(4)*7/8;
for is = 1:numel(AllStyles)
    addStyle(th,AllStyles(is),'cell',[1 is+1]);
end
message = 'Showed roi';
mtoolobj(1).Parent.StopWait;
end