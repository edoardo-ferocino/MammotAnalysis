function message = DeleteBorder(mtoolobj,type)
message = 'Error. No roi selected. Tool not applied';
selectedrois = vertcat(mtoolobj.Roi.Selected);
if sum(selectedrois)==0, return, end
IDselectedrois =  {num2str([mtoolobj.Roi(selectedrois).ID],'%d,')};
IDselectedrois = IDselectedrois{:};IDselectedrois(end)=[];
selectedrois=find(selectedrois);
for is = 1:numel(selectedrois)
    if strcmpi(type,'external')
        mtoolobj.Axes.ImageData=mtoolobj.Axes.ImageData.*mtoolobj.Roi(selectedrois(is)).Shape.createMask;
    end
    if strcmpi(type,'internal')
        mtoolobj.Axes.ImageData=mtoolobj.Axes.ImageData.*not(mtoolobj.Roi(selectedrois(is)).Shape.createMask);
    end
    mtoolobj.Roi(selectedrois(is)).Selected = false;
end
message = ['Delete tool applied to ROI ',IDselectedrois];
end