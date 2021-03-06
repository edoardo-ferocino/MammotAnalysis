classdef maxes < handle
    % maxes Axes Class for the MammotAnalysis interface
    events
        ToolApplied             % Event triggered from application of tool
    end
    properties
        History;                % History struct for the axes
        Graphical;              % Graphical objects;
    end
    properties (Dependent)
        ImageData;              % Data of the image
        CLim;                   % Limits of the colorbar
        Selected;               % Axes is selected
        Name;                   % Name of axes
    end
    properties (SetAccess = immutable)
        Parent mfigure;         % mfigureobj as parent
        axes;                   % axes obj
        Image;                  % image obj
        Tool mtool;             % mtoolobj
        Colorbar;               % Colorbar with the axes
        OriginalCLim;           % Original values for colorbar
    end
    properties (Hidden = true)
        HistoryIndex = 1;       % index for navigation within history
        PreviousToolName = '';  % name of the previous tool applied
    end
    properties (Constant, Hidden = true)
        HighPercentile = 95;     % higher limit of percentile
        LowPercentile = 0;       % lower limit of percentile
    end
    methods (Access = ?mfigure)
        function maxesobj = maxes(axesh,mfigobj)
            % Creation of maxesobj
            maxesobj.Parent = mfigobj;
            maxesobj.axes = axesh;
            maxesobj.Image = findobj(axesh.Children,'type','image');
            if isempty(maxesobj.Image)
                maxesobj.Tool = mtool(maxesobj,maxesobj.Parent);
            else
                maxesobj.CLim = GetPercentile(maxesobj.ImageData,[maxesobj.LowPercentile maxesobj.HighPercentile]);
                maxesobj.OriginalCLim = maxesobj.CLim;
                location = 'eastoutside';
                if strcmpi(axesh.Parent.Type,'tiledlayout')
                    tlh = axesh.Parent;
                    if tlh.GridSize(1)<=tlh.GridSize(2)
                        location = 'southoutside';
                    end
                end
                if isempty(maxesobj.Colorbar)
                    maxesobj.Colorbar = colorbar(axesh,'Location',location);
                else
                    maxesobj.Colorbar.Location = location;
                end
                switch maxesobj.Name
                    case 'A'
                        colorbartitle = 'cm^{-1}';
                    case 'B'
                        colorbartitle = 'adim';
                    case {'Hb','HbO2','HbTot'}
                        colorbartitle = '\muM';
                    case {'Lipid','Collagen','Water'}
                        colorbartitle = 'mg\\cm^{3}';
                    case 'SO2'
                        colorbartitle = '%';
                    otherwise
                        if contains(maxesobj.Parent.Name,'Counts','IgnoreCase',true)
                            colorbartitle = 'ph';
                        elseif contains(maxesobj.Parent.Name,'Count rate','IgnoreCase',true)
                            colorbartitle = 'ph/s';
                        else
                            colorbartitle = 'tbd';
                        end
                end
                if contains(maxesobj.Name,'absorption','IgnoreCase',true)
                    maxesobj.Name = regexprep(maxesobj.Name,'absorption','\\mu_{a}','ignorecase');
                    colorbartitle = 'cm^{-1}';
                elseif contains(maxesobj.Name,'scattering','IgnoreCase',true)
                    maxesobj.Name = regexprep(maxesobj.Name,'scattering','\\mu_{s}''','ignorecase');
                    colorbartitle = 'cm^{-1}';
                elseif contains(maxesobj.Name,'\mu_{a}','IgnoreCase',true)
                    colorbartitle = 'cm^{-1}';
                elseif contains(maxesobj.Name,'\mu_{s}''','IgnoreCase',true)
                    colorbartitle = 'cm^{-1}';
                elseif contains(maxesobj.Name,'gate','IgnoreCase',true)
                    colorbartitle = 'counts';
                elseif contains(maxesobj.Name,'dmua','IgnoreCase',true)
                    colorbartitle = 'cm^{-1}';
                end
                maxesobj.Colorbar.Title.String = colorbartitle;
                axesh.YDir = 'reverse';
                axis(axesh,'image');
                colormap(axesh,'pink');
                shading(axesh,'interp');
                %             drawnow
                if ~isempty(axesh.XTickLabel)
                    axesh.XTickLabel=cellstr(num2str(axesh.XTick'.*maxesobj.Parent.ScaleFactor));
                    %                 maxesobj.axes.XTickLabel=cellstr(num2str(cellfun(@str2num,maxesobj.axes.XTickLabel)*maxesobj.Parent.ScaleFactor));
                end
                if ~isempty(maxesobj.axes.YTickLabel)
                    axesh.YTickLabel=cellstr(num2str(axesh.YTick'.*maxesobj.Parent.ScaleFactor));
                    %                 maxesobj.axes.YTickLabel=cellstr(num2str(cellfun(@str2num,maxesobj.axes.YTickLabel)*maxesobj.Parent.ScaleFactor));
                end
                maxesobj.History.Data = maxesobj.ImageData;
                maxesobj.History.Message = {'Original Data'};
                maxesobj.History.ToolName = 'originaldata';
                maxesobj.History.Roi = [];
                if isfield(maxesobj.Parent.Data,'PickData')
                    maxesobj.History.PickData = maxesobj.Parent.Data.PickData;
                else
                    maxesobj.History.PickData = [];
                end
                addlistener(maxesobj,'ToolApplied',@maxesobj.UpdateHistory);
                set(maxesobj.Image,'HitTest','on','PickableParts','visible','ButtonDownFcn',@maxesobj.ToogleSelect);
            end
            set(maxesobj.axes,'HitTest','on','PickableParts','visible','ButtonDownFcn',@maxesobj.ToogleSelect);
            maxesobj.Tool = mtool(maxesobj,maxesobj.Parent);
        end
    end
    methods
        ToogleSelect(maxesobj,varargin);            % axes selection
        function set.ImageData(maxesobj,newdata)    % set image data
            if isempty(maxesobj.Image), return; end
            maxesobj.Image.CData = newdata;
            maxesobj.CLim = GetPercentile(newdata,[maxesobj.LowPercentile maxesobj.HighPercentile]);
        end
        function out = get.ImageData(maxesobj)      % get image data
            if isempty(maxesobj.Image),out = false; return; end
            out = maxesobj.Image.CData;
        end
        function set.CLim(maxesobj,newdata)         % set colorbar limits
            maxesobj.axes.CLim = newdata;
        end
        function out = get.CLim(maxesobj)           % get colorbar limits
            out = maxesobj.axes.CLim;
        end
        function set.Selected(maxesobj,newdata)     % set selection of axes
            maxesobj.ToogleSelect(logic2onoff(newdata));
        end
        function out = get.Selected(maxesobj)       % get selection of axes
            out = onoff2logic(maxesobj.axes.Selected);
        end
        function set.Name(maxesobj,newdata)
            maxesobj.axes.Title.String = newdata;
        end
        function out = get.Name(maxesobj)
            out = maxesobj.axes.Title.String;
        end
    end
    methods (Access = private)
        function UpdateHistory(maxesobj,~,event)
            % Update axes history
            if ~contains(event.CustomData.ToolName,{'back','forth'})
                if contains(lower(maxesobj.PreviousToolName),{'back','forth'})
                    maxesobj.History(maxesobj.HistoryIndex+1:end) = [];
                end
                maxesobj.HistoryIndex = numel(maxesobj.History)+1;
                maxesobj.History(maxesobj.HistoryIndex,1) = event.CustomData;
                maxesobj.History(maxesobj.HistoryIndex,1).Roi = maxesobj.Tool.Roi;
                if ~isfield(maxesobj.Parent.Data,'PickData')
                    PickData = [];
                else
                    PickData = maxesobj.Parent.Data.PickData;
                end
                maxesobj.History(maxesobj.HistoryIndex,1).PickData = PickData;
            end
            if strcmpi(event.CustomData.ToolName,'historyback')
                maxesobj.HistoryIndex = maxesobj.HistoryIndex-1;
            end
            if strcmpi(event.CustomData.ToolName,'historyforth')
                maxesobj.HistoryIndex = maxesobj.HistoryIndex+1;
            end
            maxesobj.PreviousToolName = event.CustomData.ToolName;
        end
    end
end
function str = logic2onoff(logic)
if logic, str = 'on';else, str = 'off';end
end
function logical = onoff2logic(str)
if strcmpi(str,'on'), logical = true;else, logical = false;end
end
