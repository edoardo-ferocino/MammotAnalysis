function [dch,uch]=ChangeColorbar(maxesobj)
cbh=maxesobj.Colorbar;
dch = [];uch = [];
CLim=maxesobj.CLim;
downposition = [cbh.Position(1)-0.02 cbh.Position(2)-0.02 0.05 0.02];
upposition = [cbh.Position(1)-0.02 cbh.Position(2)+cbh.Position(4) 0.05 0.02];
if isempty(findobj('Tag',strcat(maxesobj.Parent.Tag,maxesobj.Name,'down')))
dch=uicontrol(maxesobj.Parent.Figure,'Style','edit','Units',cbh.Units,...
    'Position',downposition,'Callback',{@SetCLim,maxesobj,'down'},...
    'Tag',strcat(maxesobj.Parent.Tag,maxesobj.Name,'down'),'String',num2str(CLim(1)));
uch=uicontrol(maxesobj.Parent.Figure,'Style','edit','Units',cbh.Units,...
    'Position',upposition,'Callback',{@SetCLim,maxesobj,'up'},...
    'Tag',strcat(maxesobj.Parent.Tag,maxesobj.Name,'up'),'String',num2str(CLim(2)));
end
end