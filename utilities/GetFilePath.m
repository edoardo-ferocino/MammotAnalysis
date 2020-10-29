function GetFilePath(~,~,type)
global MPFOBJ
mfigobj = MPFOBJ;
mfigobj.StartWait;
switch type
    case 'fit'
        Filter = {'*.txt','FIT output'};
        DataType = 'Fit';
    case 'dat'
        Filter = {'*.dat','DAT file'};
        DataType = 'Dat';
    case 'irf'
        Filter = {'*.dat','IRF file'};
        DataType = 'Irf';
    case 'trs'
        Filter = {'*.trs','TRS settings'};
        DataType = 'TRSSet';
    case 'spe'
        Filter = {'*.spe','SPE file'};
        DataType = 'Spe';
    otherwise
        DisplayError('Format file not supported','To implement');
        return;
end
[FileName,PathName,FilterIndex]=uigetfilecustom(Filter);
if FilterIndex == 0, mfigobj.StopWait; return, end
if ~iscell(FileName)
    FileName = cellstr(FileName);
end
FullPath = fullfile(PathName,FileName);
mfigobj.Data.([DataType,'FilePath']) = FullPath;
mfigobj.Data.([DataType,'FileNumel']) = numel(FullPath);
mfigobj.Graphical.(['Disp',DataType,'FilePath']).String = strjoin(FileName,' - ');
mfigobj.StopWait;
end

