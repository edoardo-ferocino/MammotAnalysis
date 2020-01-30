function message = SelectAndApplyRefence(mtoolobj,toolname,nobjs,iobj)
persistent shape2copy
type = 'gate';
switch toolname{2}
    case 'shape'
        message = ApplyShape(mtoolobj,toolname{3},type,shape2copy);
        if nobjs>1 && iobj == 1
            shape2copy = mtoolobj.Roi(end).Shape;
        elseif iobj==nobjs
            shape2copy = [];
        end
    case 'point'
    case 'apply'
end
