function LoadFig(~)
[FileName,PathName,FilterIndex] = uigetfilecustom('*.fig','Load fig');
if FilterIndex == 0, return, end
FullPath = fullfile(PathName,FileName);
figh = open(FullPath);
mfigobj = mfigure(figh,'Name',figh.Name);
mfigobj.AddAxesToFigure;
set(mfigobj.Figure,'Color','default');
set(mfigobj.Graphical.MultiSelAxPanel,'BackgroundColor','default');
set(mfigobj.Graphical.MultiSelFigPanel,'BackgroundColor','default');
mfigobj.StopWait;
matname = strsplit(FullPath,'.'); matname = matname{1};
matname = strcat(matname,'.mat');
if isfile(matname)
    answer=questdlg({'Load data?','If no, usability is limited'},'Save data?','Yes','No','No');
    if strcmpi(answer,'yes')
        load(matname,'Data');
        mfigobj.Data = Data;
        mfigobj.Category = Data.Category;
    end
end
msgbox('Figure Loaded','Success','Help');
end