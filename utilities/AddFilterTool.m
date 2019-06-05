function AddFilterTool(parentfigure,object2attach,MFH)
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
mmh = uimenu(cmh,'Text','Filters');
FilterType = {'Median' 'Weiner' 'Gaussian'};
for ifil = 1:numel(FilterType)
   uimenu(mmh,'Text',FilterType{ifil},'Callback',{@ApplyFilter,FilterType{ifil}});
end
uimenu(mmh,'Text','Restore','Callback',{@Restore});

    function ApplyFilter(src,~,FilterType)
        src.Checked = 'On';
        switch FilterType
            case 'Median'
            object2attach.CData = medfilt2(object2attach.CData,[3 3]);
            case 'Weiner'
            object2attach.CData = wiener2(object2attach.CData,[3 3]);
            case 'Gaussian'
            object2attach.CData = imgaussfilt(object2attach.CData);
        end
    end
    function Restore(src,~)
       set(src.Parent.Children,'Checked','off')
       object2attach.CData = object2attach.UserData.OriginalCData; 
    end

end