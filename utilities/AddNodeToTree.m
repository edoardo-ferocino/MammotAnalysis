function AddNodeToTree(MFH,NodeFigH)
CategoryList = {'ROI' 'Counts' 'Wavelenghts' 'Channels' 'Spectral' 'MuaMus' 'MuaMus-Single wave' 'Filters' 'LinkFigures' 'ShiftTool' 'ChangeColorbar' 'PickCurve' 'Info' 'Profile' 'ReferenceArea' 'ReferenceRoi' 'ReferencePickCurve' 'GatesImage'};
FH=CreateOrFindFig('Figure list','uifigure',true);
StartWait(MFH);
TreeH=findobj(FH,'type','uitree');
if isempty(TreeH)
    FH.CloseRequestFcn = {@SetFigureInvisible,FH};
    MFH.UserData.SideFigs = FH;
    TreeH = uitree(FH);
    TreeH.Position(3)=TreeH.Position(3)+200;
    TreeH.Multiselect = 'on';
    FH.Position = TreeH.Position + [0 0 50 50];
    movegui(FH,'center')
    %for icats= 1: numel(CategoryList)
    %    uitreenode(TreeH,'Text',CategoryList{icats});
        TreeH.SelectionChangedFcn = {@OpenSelectedNodeFig};
    %end
    CreateUIButton(FH,'Position',[TreeH.Position(1) TreeH.Position(2)+TreeH.Position(4) 50 22] ...
        ,'Text','Expand','ButtonPushedFcn',{@ActionTree,FH,'expand'});
    CreateUIButton(FH,'Position',[TreeH.Position(1)+50 TreeH.Position(2)+TreeH.Position(4) 60 22] ...
        ,'Text','Collapse','ButtonPushedFcn',{@ActionTree,FH,'collapse'});
    CreatePushButton(MFH,'Units','Normalized','Position',[MFH.UserData.ListFiguresContainer.Position(1) MFH.UserData.ListFiguresContainer.Position(2)+MFH.UserData.ListFiguresContainer.Position(4) 0.04 0.03]...
        ,'String','Figure list','CallBack','FH=CreateOrFindFig(''Figure list'',''uifigure'',true);');
end
if isvalid(NodeFigH)
    if strcmpi(NodeFigH.UserData.FigCategory,'NoCategory')
       warning(['Add category to: ',NodeFigH.Name]);
    end
    if isempty(TreeH.Children)
        uitreenode(TreeH,'Text',NodeFigH.UserData.FigCategory);
    elseif ~strcmpi({TreeH.Children.Text},NodeFigH.UserData.FigCategory)
        uitreenode(TreeH,'Text',NodeFigH.UserData.FigCategory);
    end
    nodeh=uitreenode(TreeH.Children(strcmpi({TreeH.Children.Text},NodeFigH.UserData.FigCategory)),'Text',NodeFigH.Name,'NodeData',NodeFigH);
    if strcmpi(NodeFigH.UserData.FigCategory,'roi')||strcmpi(NodeFigH.UserData.FigCategory,'referenceroi')
        TempName=fullfile(tempdir,'roiicon.png');
        imwrite(reshape(repmat(NodeFigH.Color,16*16,1),16,16,3),TempName);
        nodeh.Icon = TempName;
        pause(1);
        delete(TempName)
    end
end
TreeH.Children(~isvalid(TreeH.Children)).delete;
TreeH.expand;
pause(0.5);
StopWait(MFH)
    function ActionTree(~,~,FH,action)
       treeH = findobj(FH,'type','uitree');treeH.(action);
    end
    function OpenSelectedNodeFig(src,~)
        nodeH=src.SelectedNodes;
        if isempty(nodeH.NodeData), return; end
        if ~isvalid(nodeH.NodeData), nodeH.delete; return; end
        if nodeH.NodeData.UserData.isFFS
            FFS(nodeH.NodeData);
        else
            figure(nodeH.NodeData);
        end
        src.SelectedNodes = [];
    end
end