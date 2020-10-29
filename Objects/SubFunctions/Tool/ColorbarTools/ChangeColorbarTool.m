function ChangeColorbarTool(maxesobj,toolname,maxessetsobjs,DuplicateAxesName,mtoolobj)
[dch,uch]=ChangeColorbar(maxesobj);
switch toolname{1}
    case 'independent'
    case 'linkequals'
        if any(strcmpi(maxesobj.Name,DuplicateAxesName))
            linked = maxessetsobjs(strcmpi(maxesobj.Name,DuplicateAxesName));
            linked = linked{:};
            dch.Callback = {@SetCLim,maxesobj,'down','link',linked};
            uch.Callback = {@SetCLim,maxesobj,'up','link',linked};
        end
    case 'linkall'
        linked = vertcat(mtoolobj.Axes);
        dch.Callback = {@SetCLim,maxesobj,'down','link',linked};
        uch.Callback = {@SetCLim,maxesobj,'up','link',linked};
end
end