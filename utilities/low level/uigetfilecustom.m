function [FileName,PathName,FilterIndex]=uigetfilecustom(varargin)
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
    if isfolder(fileparts(Filter))
        [FileName,PathName,FilterIndex] = uigetfile(Filter,Title,'MultiSelect','on');
    else
        [FileName,PathName,FilterIndex] = uigetfile(Filter,Title,PathName,'MultiSelect','on');
    end
else
    [FileName,PathName,FilterIndex] = uigetfile(varargin{:},'MultiSelect','on');
end
if FilterIndex == 0, return, end
save(TempPath,'PathName');
end