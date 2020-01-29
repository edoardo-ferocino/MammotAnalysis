function figobj = SelectMultipleFigures(mfigobj,~,~,operation)
% Open multiple figure selection tool
allmfigobjs=mfigobj.GetAllFigs('all');
treemfigobj = mfigure('Name','Multiple figure selection','Tag','FigureSelection','uifigure','true','Category','Selection');
allmfigobjs = setdiff(allmfigobjs,treemfigobj);
if strcmpi(operation,'show')
    treemfigobj.Figure.Name = 'Open figures';
else
    treemfigobj.Figure.Name = 'Multiple figure selection';
end
treeh=findobj(treemfigobj.Figure,'type','uitree');
if isempty(treeh)
    mfigobj.StartWait
    treeh = uitree(treemfigobj.Figure);
    treeh.Multiselect = 'on';
    treeh.Position(3)=treeh.Position(3)+300;
    treeh.FontWeight = 'bold';
    treemfigobj.Figure.Position(3:4)= treeh.Position(3:4) + [50 50];
    mfigobj.StopWait
end
treeh.SelectionChangedFcn = {@GetSelection,allmfigobjs,operation};
dbh=uibutton(treemfigobj.Figure,'Position',[treeh.Position(1) treeh.Position(2)+treeh.Position(4) 60 22] ...
    ,'Text','Deselect','ButtonPushedFcn',{@Deselect,allmfigobjs,treeh,operation});
uibutton(treemfigobj.Figure,'Position',[treeh.Position(1)+dbh.Position(3) treeh.Position(2)+treeh.Position(4) 60 22] ...
    ,'Text','Ok','ButtonPushedFcn',@OkAndClose);
delete(treeh.Children);
movegui(treemfigobj.Figure,'center')
allcategories = arrayfun(@(iaf)allmfigobjs(iaf).Category,1:numel(allmfigobjs),'UniformOutput',false);
singlecategories = unique(allcategories);
categorynodes = cellfun(@(sc) uitreenode(treeh,'Text',sc),singlecategories);
for icn = 1:numel(categorynodes)
    categorynodes(icn).NodeData = 'categorynode';
    arrayfun(@(iaf) uitreenode(categorynodes(icn),'Text',allmfigobjs(iaf).Name,'NodeData',allmfigobjs(iaf)),find(strcmpi(allcategories,categorynodes(icn).Text)));
end
expand(treeh,'all');
pause(0.5);
drawnow
figobj = treemfigobj;
end
function GetSelection(treeh,event,allmfigobjs,operation)
actnode = setdiff(event.SelectedNodes,event.PreviousSelectedNodes);
if numel(event.SelectedNodes)==1
    if any(eq(event.SelectedNodes,event.PreviousSelectedNodes))
        actnode = event.PreviousSelectedNodes(eq(event.SelectedNodes,event.PreviousSelectedNodes));
    end
end
if isempty(actnode), return, end
if strcmpi(actnode.NodeData,'categorynode')
    nodes = setdiff(treeh.SelectedNodes,actnode);
    nodes = [nodes;actnode.Children];
    treeh.SelectedNodes = nodes;
end
arrayfun(@(ifs)SetSelectToValue(allmfigobjs(ifs),false,operation),1:numel(allmfigobjs));
arrayfun(@(isn)SetSelectToValue(treeh.SelectedNodes(isn).NodeData,true,operation),1:numel(treeh.SelectedNodes));
end
function SetSelectToValue(mfigobj,value,operation)
if strcmpi(operation,'show')
    if value == true
        mfigobj.Show
    end
else
    if mfigobj.nAxes == 0, return, end
    mfigobj.Selected = value;
end
end
function Deselect(~,~,allmfigobjs,treeh,operation)
arrayfun(@(ifs)SetSelectToValue(allmfigobjs(ifs),false,operation),1:numel(allmfigobjs));
treeh.SelectedNodes = [];
end
function OkAndClose(treeh,~)
close(treeh.Parent);
end