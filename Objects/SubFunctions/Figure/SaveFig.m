function SaveFig(mfigobj)
PathName = uigetdircustom('Select destination');
if PathName == 0, return, end
FullPath = fullfile(PathName,mfigobj.Figure.Name);
funhandles = cell(mfigobj.nSubMenu+mfigobj.nAxes*2+3);
ifh = 1;
for im= 1:mfigobj.nSubMenu
    funhandles{ifh} =  mfigobj.SubMenu(im).MenuSelectedFcn;
    mfigobj.SubMenu(im).MenuSelectedFcn = [];
    ifh = ifh +1;
end
for ia = 1:mfigobj.nAxes
    funhandles{ifh} = mfigobj.Axes(ia).axes.ButtonDownFcn;
    mfigobj.Axes(ia).axes.ButtonDownFcn = [];
    ifh = ifh +1;
    funhandles{ifh} = mfigobj.Axes(ia).Image.ButtonDownFcn;
    mfigobj.Axes(ia).Image.ButtonDownFcn = [];
    ifh = ifh +1;
end
funhandles{ifh} = mfigobj.Figure.ButtonDownFcn;
mfigobj.Figure.ButtonDownFcn = [];
ifh = ifh +1;
funhandles{ifh} = mfigobj.Figure.CloseRequestFcn;
mfigobj.Figure.CloseRequestFcn = [];
ifh = ifh +1;
funhandles{ifh} = mfigobj.Figure.KeyPressFcn;
mfigobj.Figure.KeyPressFcn = [];
if any(vertcat(mfigobj.Tools.nRoi))
    answer=questdlg('Preserve annotations?','What should I do?','Yes','No','No');
    if strcmpi(answer,'no')
        Rois = vertcat(mfigobj.Tools.Roi);
        Rois = vertcat(Rois.Shape);
        for ir = 1:numel(Rois)
            Rois(ir).Visible = false;
        end
    end
end
answer=questdlg({'Save data (time&space consuming)?','Yes to fully use saved fig'},'Save data?','Yes','No','No');
if strcmpi(answer,'yes')
    Data = mfigobj.Data;
    save(FullPath,'Data','-v7.3');
end

save_figure(FullPath,mfigobj.Figure,'-png','-pdf','-svg');

ifh = 1;
for im= 1:mfigobj.nSubMenu
    mfigobj.SubMenu(im).MenuSelectedFcn = funhandles{ifh};
    ifh = ifh + 1;
end
for ia = 1:mfigobj.nAxes
    mfigobj.Axes(ia).axes.ButtonDownFcn = funhandles{ifh};
    ifh = ifh + 1;
    mfigobj.Axes(ia).Image.ButtonDownFcn = funhandles{ifh};
    ifh = ifh + 1;
end
mfigobj.Figure.ButtonDownFcn = funhandles{ifh};
ifh = ifh + 1;
mfigobj.Figure.CloseRequestFcn = funhandles{ifh};
ifh = ifh + 1;
mfigobj.Figure.KeyPressFcn = funhandles{ifh};
if exist('Rois','var')
    for ir = 1:numel(Rois)
        Rois(ir).Visible = true;
    end
end

msgbox('Figure saved','Success','Help');
end