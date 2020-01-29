function message = NameRoi(mtoolobj,toolname)
message = 'Error. No roi selected. Tool not applied';
selectedrois = vertcat(mtoolobj.Roi.Selected);
if sum(selectedrois)==0, return; end
IDselectedrois =  {num2str([mtoolobj.Roi(selectedrois).ID],'%d,')};
IDselectedrois = IDselectedrois{:};IDselectedrois(end)=[];
selectedrois=find(selectedrois);
for is = 1:numel(selectedrois)
    mtoolobj.Roi(selectedrois(is)).RoiValues.Name = toolname{1};
    mtoolobj.Roi(selectedrois(is)).Name = toolname{1};
end
message = ['Named Roi ',IDselectedrois,' as ', toolname{1}];
end