function [message,newcolor] = ChangeRoiColor(mtoolobj,newcolor)
if isempty(newcolor)
   newcolor = uisetcolor;
end
shapeobjs = vertcat(mtoolobj.Roi(vertcat(mtoolobj.Roi.Selected)).Shape);
for is = 1:numel(shapeobjs)
   shapeobjs(is).Color = newcolor; 
end
IDselectedrois =  {num2str([mtoolobj.Roi(vertcat(mtoolobj.Roi.Selected)).ID],'%d,')};
IDselectedrois = IDselectedrois{:};IDselectedrois(end)=[];
message = ['Changed color to Roi ',IDselectedrois];
end