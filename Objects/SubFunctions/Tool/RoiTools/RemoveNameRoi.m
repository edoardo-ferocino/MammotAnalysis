function message = RemoveNameRoi(mtoolobj)
message = 'Error. No roi selected. Tool not applied';
selectedrois = vertcat(mtoolobj.Roi.Selected);
if sum(selectedrois)==0, return; end
IDselectedrois =  {num2str([mtoolobj.Roi(selectedrois).ID],'%d,')};
IDselectedrois = IDselectedrois{:};IDselectedrois(end)=[];
selectedrois=find(selectedrois);
for is = 1:numel(selectedrois)
    mtoolobj.Roi(selectedrois(is)).Name = char.empty;
end
message = ['Removed Names to Roi ',IDselectedrois];
end