function CreateMenuSelectFunctions(mfigobj)
% Create the function for menu selections
for im = 1:mfigobj.nSubMenu
    if numel(mfigobj.SubMenu(im).Children)==0
        mfigobj.SubMenu(im).MenuSelectedFcn = @mfigobj.ToolSelection;
    end
    if contains(mfigobj.GetToolName(mfigobj.SubMenu(im)),'selectallaxes','IgnoreCase',true)
        mfigobj.SubMenu(im).MenuSelectedFcn = @mfigobj.SelectAllAxes;
    end
    if contains(mfigobj.GetToolName(mfigobj.SubMenu(im)),'selectfigures','IgnoreCase',true)
        mfigobj.SubMenu(im).MenuSelectedFcn = {@(src,event)mfigobj.SelectMultipleFigures(src,event,'select')};
    end
    if contains(mfigobj.GetToolName(mfigobj.SubMenu(im)),'selectdeselectall','IgnoreCase',true)
        mfigobj.SubMenu(im).MenuSelectedFcn = @mfigobj.DeselectAll;
    end
    if contains(mfigobj.GetToolName(mfigobj.SubMenu(im)),'selectopenfigures','IgnoreCase',true)
        mfigobj.SubMenu(im).MenuSelectedFcn = {@(src,event)mfigobj.SelectMultipleFigures(src,event,'show')};
    end
    if contains(mfigobj.GetToolName(mfigobj.SubMenu(im)),'actionshowmainpanel','IgnoreCase',true)
        mfigobj.SubMenu(im).MenuSelectedFcn = @mfigobj.ShowMainPanel;
    end
    if contains(mfigobj.GetToolName(mfigobj.SubMenu(im)),'actionexit','IgnoreCase',true)
        mfigobj.SubMenu(im).MenuSelectedFcn = @mfigobj.Exit;
    end
    if contains(mfigobj.GetToolName(mfigobj.SubMenu(im)),'figuresload','IgnoreCase',true)
        mfigobj.SubMenu(im).MenuSelectedFcn = @mfigobj.Load;
    end
    if contains(mfigobj.GetToolName(mfigobj.SubMenu(im)),'figuressave','IgnoreCase',true)
        mfigobj.SubMenu(im).MenuSelectedFcn = @mfigobj.Save;
    end
end
end
