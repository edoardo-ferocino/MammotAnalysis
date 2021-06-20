function message = LoadRoi(mtoolobj)
message = ['Loaded Rois'];
[FileName,PathName,FilterIndex]=uigetfilecustom({'*.mat','MAT file'});
if FilterIndex == 0, message = ['Loaded Rois aborted']; return, end
if ~iscell(FileName)
    FileName = cellstr(FileName);
end
FullPath = fullfile(PathName,FileName);

for ifl = 1:numel(FullPath)
    load(FullPath{ifl});
    ApplyShape(mtoolobj,Roi.Shape,Roi.Type,Roi);
end
end