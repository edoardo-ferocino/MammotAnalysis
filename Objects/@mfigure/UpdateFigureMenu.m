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
%     if status(isbm)>1
%         mfigobj.SubMenu(isbm).Text = [mfigobj.SubMenu(isbm).Text '(' num2str(status(isbm)) ')'];
%     else
%         Text=split(mfigobj.SubMenu(isbm).Text,'(');
%         mfigobj.SubMenu(isbm).Text=Text{1};
%     end
end
end