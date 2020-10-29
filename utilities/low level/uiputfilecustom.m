function [FileName,PathName,FilterIndex]=uiputfilecustom(varargin)
AppDataTempPath = getapplicationdatadir(fullfile('\Temp'),false,true);
TempPath = fullfile(AppDataTempPath,'temppath.mat');
if exist(TempPath,'file')
    load(TempPath,'PathName');
    Filter = '*.*';Title='Select File to Open';
    switch nargin
        case 1
            Filter = varargin{1};
        case 2
            Filter = varargin{1};Title = varargin{2};
    end
    [FileName,PathName,FilterIndex] = uiputfile(Filter,Title,PathName);
else
    [FileName,PathName,FilterIndex] = uiputfile(varargin{:});
end
if FilterIndex == 0, return, end
save(TempPath,'PathName');
end