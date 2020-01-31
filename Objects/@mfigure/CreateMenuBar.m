function CreateMenuBar(mfigobj)
% Create menus for tool selection
mfigobj.Figure.MenuBar = 'none';
mfigobj.Figure.ToolBar = 'none';
if ~isempty(findobj(mfigobj.Figure,'type','uimenu')) %controllare e migliorare
    return
end
if ~strcmpi(mfigobj.Tag,mfigobj.MainPanelTag)
    mfigobj.Figure.ToolBar = 'figure';
    %% Filter tools
    fmh=uimenu(mfigobj.Figure,'Text','&Filter','Tag',[mfigobj.Tag mfigobj.spacer 'Filter']);
    uimenu(fmh,'Text','&Median Mask','Tag',[fmh.Tag mfigobj.spacer 'MedianMask']);
    uimenu(fmh,'Text','&Median','Tag',[fmh.Tag mfigobj.spacer 'Median']);
    uimenu(fmh,'Text','&Gaussian','Tag',[fmh.Tag mfigobj.spacer 'Gaussian']);
    uimenu(fmh,'Text','&Weiner','Tag',[fmh.Tag mfigobj.spacer 'Weiner']);
    uimenu(fmh,'Text','&NonLocalMean','Tag',[fmh.Tag mfigobj.spacer 'NonLocalMean']);
    uimenu(fmh,'Text','&Diffuse','Tag',[fmh.Tag mfigobj.spacer 'Diffuse']);
    uimenu(fmh,'Text','&ClearBorder','Tag',[fmh.Tag mfigobj.spacer 'ClearBorder']);
    %% Colorbar tools
    cbmh=uimenu(mfigobj.Figure,'Text','&Colorbar','Tag',[mfigobj.Tag mfigobj.spacer 'Colorbar']);
    ccbmh=uimenu(cbmh,'Text','&Change','Tag',[cbmh.Tag mfigobj.spacer 'Change']);
    uimenu(ccbmh,'Text','&Independent','Tag',[ccbmh.Tag mfigobj.spacer 'Independent']);
    uimenu(ccbmh,'Text','Link &equals','Tag',[ccbmh.Tag mfigobj.spacer 'LinkEquals']);
    uimenu(ccbmh,'Text','Link &all','Tag',[ccbmh.Tag mfigobj.spacer 'LinkAll']);
    uimenu(cbmh,'Text','&Restore','Tag',[cbmh.Tag mfigobj.spacer 'Restore']);
    %% Overlap tools
    omh=uimenu(mfigobj.Figure,'Text','&Overlap','Tag',[mfigobj.Tag mfigobj.spacer 'Overlap']);
    uimenu(omh,'Text','&Drawing','Tag',[mfigobj.Tag mfigobj.spacer 'Drawing']);
    %% Measure tools
    mdh=uimenu(mfigobj.Figure,'Text','&Measure','Tag',[mfigobj.Tag mfigobj.spacer 'Measure']);
    uimenu(mdh,'Text','&Distance','Tag',[mdh.Tag mfigobj.spacer 'Distance']);
    uimenu(mdh,'Text','&Perimeter','Tag',[mdh.Tag mfigobj.spacer 'Perimeter']);
    uimenu(mdh,'Text','&Area','Tag',[mdh.Tag mfigobj.spacer 'Area']);
    %% Compare tools
    cmh=uimenu(mfigobj.Figure,'Text','C&ompare','Tag',[mfigobj.Tag mfigobj.spacer 'Compare']);
    uimenu(cmh,'Text','&New compare figure','Tag',[cmh.Tag mfigobj.spacer 'new']);
    uimenu(cmh,'Text','&Specific compare figure','Tag',[cmh.Tag mfigobj.spacer 'existent']);
    %% Roi tools
    rmh=uimenu(mfigobj.Figure,'Text','&Roi','Tag',[mfigobj.Tag mfigobj.spacer 'Roi']);
    rsmh=uimenu(rmh,'Text','&Shape','Tag',[rmh.Tag mfigobj.spacer 'Shape']);
    uimenu(rsmh,'Text','&Rectangle','Tag',[rsmh.Tag mfigobj.spacer 'Rectangle'],'Accelerator','r');
    uimenu(rsmh,'Text','&FreeHand','Tag',[rsmh.Tag mfigobj.spacer 'Freehand']);
    uimenu(rsmh,'Text','&Circle','Tag',[rsmh.Tag mfigobj.spacer 'Circle']);
    uimenu(rsmh,'Text','&Entire image','Tag',[rsmh.Tag mfigobj.spacer 'EntireImage'],'Accelerator','i');
    uimenu(rmh,'Text','&Copy','Tag',[rmh.Tag mfigobj.spacer 'Copy'],'Accelerator','c');
    uimenu(rmh,'Text','&Paste','Tag',[rmh.Tag mfigobj.spacer 'Paste'],'Accelerator','v');
    uimenu(rmh,'Text','&Delete','Tag',[rmh.Tag mfigobj.spacer 'Delete']);
    nrmh=uimenu(rmh,'Text','&Name','Tag',[rmh.Tag mfigobj.spacer 'Name']);
    uimenu(nrmh,'Text','&Lesion','Tag',[nrmh.Tag mfigobj.spacer 'Lesion']);
    uimenu(nrmh,'Text','&Background','Tag',[nrmh.Tag mfigobj.spacer 'Background']);
    uimenu(nrmh,'Text','&External','Tag',[nrmh.Tag mfigobj.spacer 'External']);
    uimenu(nrmh,'Text','&Internal','Tag',[nrmh.Tag mfigobj.spacer 'Internal']);
    uimenu(nrmh,'Text','&Other','Tag',[nrmh.Tag mfigobj.spacer 'Other']);
    uimenu(rmh,'Text','&Show','Tag',[rmh.Tag mfigobj.spacer 'Show'],'Accelerator','q');
    uimenu(rmh,'Text','&Move together','Tag',[rmh.Tag mfigobj.spacer 'movetogether']);
    %     uimenu(rmh,'Text','&Interrupt move together','Tag',[rmh.Tag mfigobj.spacer 'stopmovetogether']);
    %% Border tools
    bmh=uimenu(mfigobj.Figure,'Text','Define &border','Tag',[mfigobj.Tag mfigobj.spacer 'Border']);
    sbmh=uimenu(bmh,'Text','&Shape','Tag',[bmh.Tag mfigobj.spacer 'Shape']);
    uimenu(sbmh,'Text','&Rectangle','Tag',[sbmh.Tag mfigobj.spacer 'Rectangle']);
    uimenu(sbmh,'Text','&FreeHand','Tag',[sbmh.Tag mfigobj.spacer 'Freehand']);
    uimenu(sbmh,'Text','&Circle','Tag',[sbmh.Tag mfigobj.spacer 'Circle']);
    dbmh=uimenu(bmh,'Text','&Delete','Tag',[bmh.Tag mfigobj.spacer 'DeleteBorder']);
    uimenu(dbmh,'Text','&External','Tag',[dbmh.Tag mfigobj.spacer 'External']);
    uimenu(dbmh,'Text','&Internal','Tag',[dbmh.Tag mfigobj.spacer 'Internal']);
    uimenu(bmh,'Text','&Copy','Tag',[bmh.Tag mfigobj.spacer 'Copy']);
    uimenu(bmh,'Text','&Paste','Tag',[bmh.Tag mfigobj.spacer 'Paste']);
    uimenu(bmh,'Text','&Move together','Tag',[bmh.Tag mfigobj.spacer 'movetogether']);
    uimenu(bmh,'Text','&Interrupt move together','Tag',[bmh.Tag mfigobj.spacer 'stopmovetogether']);
    %% History tools
    hmh=uimenu(mfigobj.Figure,'Text','&History','Tag',[mfigobj.Tag mfigobj.spacer 'History']);
    uimenu(hmh,'Text','&Back','Tag',[hmh.Tag mfigobj.spacer 'Back'],'Accelerator','z');
    uimenu(hmh,'Text','&Forth','Tag',[hmh.Tag mfigobj.spacer 'Forth'],'Accelerator','y');
    uimenu(hmh,'Text','&Show','Tag',[hmh.Tag mfigobj.spacer 'Show']);
    %% Profile tools
    hmh=uimenu(mfigobj.Figure,'Text','&Profile','Tag',[mfigobj.Tag mfigobj.spacer 'Profile']);
    uimenu(hmh,'Text','&Row','Tag',[hmh.Tag mfigobj.spacer 'Row']);
    uimenu(hmh,'Text','&Column','Tag',[hmh.Tag mfigobj.spacer 'Column']);
    uimenu(hmh,'Text','&Arbitrary','Tag',[hmh.Tag mfigobj.spacer 'ImProfile']);
    %% Pick on image tools
    poimh=uimenu(mfigobj.Figure,'Text','Pick on &Image','Tag',[mfigobj.Tag mfigobj.spacer 'PickOnImage']);
    uimenu(poimh,'Text','&Curve','Tag',[poimh.Tag mfigobj.spacer 'Curve']);
    uimenu(poimh,'Text','&Spectra','Tag',[poimh.Tag mfigobj.spacer 'Spectra']);
    poiimh=uimenu(poimh,'Text','&Info','Tag',[poimh.Tag mfigobj.spacer 'Info']);
    uimenu(poiimh,'Text','&Activated','Tag',[poiimh.Tag mfigobj.spacer 'Activated']);
    %% Gate tools
    gmh=uimenu(mfigobj.Figure,'Text','&Gate tools','Tag',[mfigobj.Tag mfigobj.spacer 'Gate'],'Accelerator','g');
    gsrmh=uimenu(gmh,'Text','&Select Reference','Tag',[gmh.Tag mfigobj.spacer 'Reference']);
    gssrmh=uimenu(gsrmh,'Text','&Shape','Tag',[gsrmh.Tag mfigobj.spacer 'Shape']);
    uimenu(gssrmh,'Text','&Rectangle','Tag',[gssrmh.Tag mfigobj.spacer 'Rectangle']);
    uimenu(gssrmh,'Text','&FreeHand','Tag',[gssrmh.Tag mfigobj.spacer 'Freehand']);
    uimenu(gssrmh,'Text','&Circle','Tag',[gssrmh.Tag mfigobj.spacer 'Circle']);
    uimenu(gsrmh,'Text','&Point','Tag',[gsrmh.Tag mfigobj.spacer 'Point']);
    uimenu(gmh,'Text','&Apply Reference','Tag',[gmh.Tag mfigobj.spacer 'Apply']);
    %% Separator
    uimenu(mfigobj.Figure,'Text','|','Tag',[mfigobj.Tag mfigobj.spacer 'Separator'],'Enable','off');
end
%% Select tools
smh=uimenu(mfigobj.Figure,'Text','&Select','Tag',[mfigobj.Tag mfigobj.spacer 'Select']);
uimenu(smh,'Text','All &Axes','Tag',[smh.Tag mfigobj.spacer 'AllAxes'],'Accelerator','a');
uimenu(smh,'Text','Multiple &Figures','Tag',[smh.Tag mfigobj.spacer 'Figures'],'Accelerator','f');
uimenu(smh,'Text','&Deselect All','Tag',[smh.Tag mfigobj.spacer 'DeselectAll'],'Accelerator','d');
uimenu(smh,'Text','Figure from &list','Tag',[smh.Tag mfigobj.spacer 'OpenFigures'],'Accelerator','x');
%% Actions
amh=uimenu(mfigobj.Figure,'Text','&Action','Tag',[mfigobj.Tag mfigobj.spacer 'Action']);
uimenu(amh,'Text','Show Main &Panel','Tag',[amh.Tag mfigobj.spacer 'ShowMainPanel'],'Accelerator','m');
uimenu(amh,'Text','&Exit','Tag',[amh.Tag mfigobj.spacer 'Exit'],'Accelerator','e');
%% Add menus to mfigure object
allmh = findobj(mfigobj.Figure,'type','uimenu');
mfigobj.Menu = allmh;
mfigobj.nMenu = numel(allmh);
mfigobj.MainMenu = allmh(arrayfun(@(im)strcmpi(allmh(im).Parent.Type,'figure'),1:mfigobj.nMenu));
mfigobj.SubMenu = setdiff(mfigobj.Menu,mfigobj.MainMenu);
mfigobj.nMainMenu = numel(mfigobj.MainMenu);
mfigobj.nSubMenu = numel(mfigobj.SubMenu);
end