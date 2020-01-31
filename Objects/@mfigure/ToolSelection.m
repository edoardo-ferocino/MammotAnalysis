function ToolSelection(mfigobj,menuobj,~)
% Respond to menu selection
allmfigobjs=mfigobj.GetAllFigs;
if mfigobj.nTool == 0, return, end
if sum(vertcat(mfigobj.Axes.Selected))==0 && sum(vertcat(allmfigobjs.Selected))==0
    msgbox('Select at least one axes','Selection','help')
    return
end
if ~strcmpi(menuobj.Checked,'on')
    action = 'Apply';
else
    action = 'Remove';
end
if any(vertcat(allmfigobjs.Selected))
    allmfigobjs=allmfigobjs(vertcat(allmfigobjs.Selected));
    alltoolsobjs = vertcat(allmfigobjs.Tools);
    selectedmtoolobjindeces=arrayfun(@(ifs)vertcat(allmfigobjs(ifs).Axes.Selected),1:numel(allmfigobjs),'UniformOutput',false);
    alltoolsobjs=alltoolsobjs(vertcat(selectedmtoolobjindeces{:}));
else
    alltoolsobjs = mfigobj.Tools(vertcat(mfigobj.Axes.Selected)); 
end
alltoolsobjs.(action)(menuobj);
end