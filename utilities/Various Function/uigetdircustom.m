function PathName=uigetdircustom(varargin)
AppDataTempPath = getapplicationdatadir(fullfile('\Temp'),false,true);
TempPath = fullfile(AppDataTempPath,'temppath.mat');
if exist(TempPath,'file')    % Load the Sim.mat file
    load(TempPath,'PathName');
    switch numel(varargin)
        case 0
            Title = 'Select destination folder';
        case 1
            Title = varargin{1};
    end
    PathName = uigetdir(PathName,Title);
    
else
    PathName = uigetdir(varargin{:});
    
end
if PathName == 0, return, end
VarArgin = varargin;
if isempty(VarArgin)
    save(TempPath,'PathName');
else
    save(TempPath,'PathName','VarArgin');
end
end