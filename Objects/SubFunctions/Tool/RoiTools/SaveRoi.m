function message = SaveRoi(mtoolobj)
selectedrois = vertcat(mtoolobj.Roi.Selected);
if sum(selectedrois)==0, return; end
IDselectedrois =  {num2str([mtoolobj.Roi(selectedrois).ID],'%d,')};
IDselectedrois = IDselectedrois{:};IDselectedrois(end)=[];
selectedrois = find(selectedrois);
for is = 1:numel(selectedrois)
    DirName = fullfile('Roi',mtoolobj.Roi(is).Tool.Parent.Data.FileName);
    if ~exist(DirName,'dir')
        mkdir(DirName)
    end
    DirName = fullfile(DirName,erase(mtoolobj.Roi(is).Tool.Parent.Figure.Name,[' - ',mtoolobj.Roi(is).Tool.Parent.Data.FileName]));
    if ~exist(DirName,'dir')
        mkdir(DirName)
    end
    NewFileName = strjoin({mtoolobj.Roi(is).Tool.Axes.Name,num2str(mtoolobj.Roi(is).ID)},'-');
    NewFileName = regexprep(NewFileName,'[\/\\*:?"<>|.]+','-');
    NewFileName = fullfile(DirName,NewFileName);
    Roi.Position = mtoolobj.Roi(is).Shape.Position;
    shapetype=split(mtoolobj.Roi(is).Shape.Type,'.');shapetype=shapetype{3};
    Roi.Shape = shapetype;
    Roi.Type = mtoolobj.Roi(is).Type;
    save(NewFileName,'Roi')
end
message = ['Saved Rois',IDselectedrois];
end