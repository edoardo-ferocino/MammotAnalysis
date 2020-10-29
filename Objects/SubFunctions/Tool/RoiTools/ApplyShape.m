function message = ApplyShape(mtoolobj,shape,type,shape2copy)
if isempty(mtoolobj.Roi)
    mtoolobj.Roi= mroi(mtoolobj,shape,type,shape2copy);
else
    mtoolobj.Roi(end+1,1) = mroi(mtoolobj,shape,type,shape2copy);
end
message = ['Applied ', shape, '. ROI ', num2str(mtoolobj.Roi(end).ID)];
end
