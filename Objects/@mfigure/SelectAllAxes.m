function SelectAllAxes(mfigobj,menuobj,~)
%Select all axes within a figure
if strcmpi(menuobj.Checked,'on')
    mfigobj.Axes.ToogleSelect('off');
    menuobj.Checked = 'off';
else
    mfigobj.Axes.ToogleSelect('on');
    menuobj.Checked = 'on';
end
end