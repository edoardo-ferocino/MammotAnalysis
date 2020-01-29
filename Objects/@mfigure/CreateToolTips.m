function CreateToolTips(obj)
findobj(obj.Figure,'-regexp','Tag',[obj.Tag obj.spacer]);
for im = 1:obj.nMenu
   toolname = obj.GetToolName(obj.Menu(im));
   tooltip = 'suggestion missing';
   switch toolname
       case 'filter'
           tooltip = 'Apply several filters on image';
       case 'overlap'
           tooltip = 'Overalp breast profile';
   end
   obj.Menu(im).Tooltip = tooltip; 
end
end