function message = DeleteRoi(mtoolobj)
selectedrois = vertcat(mtoolobj.Roi.Selected);
if sum(selectedrois)==0, return; end
IDselectedrois =  {num2str([mtoolobj.Roi(selectedrois).ID],'%d,')};
IDselectedrois = IDselectedrois{:};IDselectedrois(end)=[];
delete(vertcat(mtoolobj.Roi(selectedrois).Shape));
message = ['Deleted Roi ',IDselectedrois];
end