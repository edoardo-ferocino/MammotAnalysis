function UpdateFigureMenu(mfigobj,~,~)
% Update menu on selection
status = false(mfigobj.nSubMenu,1);
for iax = 1:mfigobj.nAxes
    if mfigobj.Axes(iax).Selected
        status = status+logical(struct2array(mfigobj.Tools(iax).Status)');
    end
end
for isbm = 1:mfigobj.nSubMenu
    mfigobj.SubMenu(isbm).Checked = status(isbm);
    if status(isbm)>1
        mfigobj.SubMenu(isbm).Text = [mfigobj.SubMenu(isbm).UserData.OriginalText '(' num2str(status(isbm)) ')'];
    else
        if ~strcmp(mfigobj.SubMenu(isbm).Text,mfigobj.SubMenu(isbm).UserData.OriginalText)
            mfigobj.SubMenu(isbm).Text=mfigobj.SubMenu(isbm).UserData.OriginalText;
        end
    end
end

if sum(vertcat(mfigobj.Axes.Selected))>1
   mfigobj.Graphical.MultiSelAxPanel.BackgroundColor = 'yellow';
   mfigobj.Graphical.MultiSelAxPanel.Title = num2str(sum(vertcat(mfigobj.Axes.Selected)));
else
   mfigobj.Graphical.MultiSelAxPanel.BackgroundColor = mfigobj.Figure.Color;
   mfigobj.Graphical.MultiSelAxPanel.Title = char.empty;
end

end