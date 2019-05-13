function GetFilePath(~,~,type,MFH)
[FileName,PathName,FilterIndex]=uigetfilecustom('*.txt;*.dat;*.fit;*.trs');
if FilterIndex == 0, return, end
if ~iscell(FileName)
    FileName = cellstr(FileName);
end
FullPath = fullfile(PathName,FileName);
switch type
    case 'fit'
        DataType = 'Fit';
    case 'dat'
        DataType = 'Dat';
    case 'irf'
        DataType = 'Irf';
    case 'trs'
        DataType = 'TRSSet';
end

MFH.UserData.([DataType,'FilePath']) = FullPath;
MFH.UserData.([DataType,'FileNumel']) = numel(FullPath);
MFH.UserData.(['Disp',DataType,'FilePath']).String = strjoin(FileName,',');
end

