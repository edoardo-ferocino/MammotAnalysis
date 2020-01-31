classdef maxes < handle
    % maxes Axes Class for the MammotAnalysis interface
    events
        ToolApplied             % Event triggered from application of tool
    end
    properties
        History;                % History struct for the axes
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
        ScaleFactor = 1;
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
            maxesobj.Image = findobj(axesh,'type','image');
            if isempty(maxesobj.Image)
                maxesobj.Tool = mtool(maxesobj,maxesobj.Parent);
                return;
            end
            maxesobj.CLim = GetPercentile(maxesobj.ImageData,[maxesobj.LowPercentile maxesobj.HighPercentile]);
            maxesobj.OriginalCLim = maxesobj.CLim;
            location = 'eastoutside';
            if strcmpi(axesh.Parent.Type,'tiledlayout')
                tlh = axesh.Parent;
                if tlh.GridSize(1)>1
                    location = 'southoutside';
                end
            end
            maxesobj.Colorbar = colorbar(axesh,'Location',location);
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
                    colorbartitle = 'tbd';
            end
            if contains(maxesobj.Name,'absorption','IgnoreCase',true)
                maxesobj.Name = regexprep(maxesobj.Name,'absorption','\\mu_{a}','ignorecase');
                colorbartitle = 'cm^{-1}';
            elseif contains(maxesobj.Name,'scattering','IgnoreCase',true)
                maxesobj.Name = regexprep(maxesobj.Name,'scattering','\\mu_{s}''','ignorecase');
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
            addlistener(maxesobj,'ToolApplied',@maxesobj.UpdateHistory);
            set(maxesobj.Image,'HitTest','on','PickableParts','visible','ButtonDownFcn',@maxesobj.ToogleSelect);
            set(maxesobj.axes,'HitTest','on','PickableParts','visible','ButtonDownFcn',@maxesobj.ToogleSelect);
            maxesobj.Tool = mtool(maxesobj,maxesobj.Parent);
        end
    end
    methods
        ToogleSelect(maxesobj,varargin);            % axes selection
        function set.ImageData(maxesobj,newdata)    % set image data
            if isempty(maxesobj.Image),out = false; return; end
            maxesobj.Image.CData = newdata;
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
            if isempty(maxesobj.Image),out = false; return; end
            maxesobj.ToogleSelect(logic2onoff(newdata));
        end
        function out = get.Selected(maxesobj)       % get selection of axes
            if isempty(maxesobj.Image),out = false; return; end
            out = onoff2logic(maxesobj.Image.Selected);
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
