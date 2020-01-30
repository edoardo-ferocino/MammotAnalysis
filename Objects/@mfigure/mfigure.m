classdef mfigure < handle
    %mfigure Figure Class for the MammotAnalysis interface
    events
        AxesSelection           %event triggered by axes selection. Cause the update of the figure menu status
    end
    properties
        Figure;                 %figure
        Category;               %category of figure (spectral,counts...)
        FigType;                %figure type: containing data or adjoints
        Name;                   %figure name
        Axes maxes;             %axes object handle (one for each axes)
        Tools mtool;            %tool object handle (one for each axes)
        Graphical;              % general graphical handles
        Data;                   % similar to UserData
    end
    properties (SetAccess = immutable)
        Tag;                    %figure tag. Unique identifier
    end
    properties (Constant = true,Hidden = true)
        spacer = '%';           %spacer for toolnames
        TagBase = 'mfigure';    %tag base name
        SelectedColor = [1 0.87 0.87];  %color for selection
        MainPanelTag = strcat('mfigure%MainPanel');
    end
    properties (Constant)
        Wavelengths = [635 680 785 905 933 975 1060]';
    end
    properties (Hidden = true)
        nMenu=0;                  %numel total menus
        nMainMenu=0;              %numel main menus
        nSubMenu=0;               %numel sub menus
        Menu;                     %figure menus handle
        MainMenu;                 %main menus handle
        SubMenu;                  %submenus handle
        ScaleFactor = 1;
    end
    properties (Dependent)
        Selected;               %figure is selected for multiple apply of tools (or shortcut for selecting all axes of a figure)
    end
    properties (Dependent,Hidden = true)
        nAxes;                  %numel axes
        nTool;                  %numel tool objects
    end
    methods
        function mfigobj = mfigure(varargin)
            %Object creator
            [figureargs,otherargsstruct]=parseInputs(varargin);
            isuifigure=otherargsstruct.uifigure;
            isvolatile=otherargsstruct.volatile;
            figh = [];
            if ishandle(figureargs{1})
                figh = figureargs{1};
                figureargs = figureargs(2:end);
            end
            tagposition=contains(figureargs,'tag','ignorecase',true);
            if ~any(tagposition)
                nameposition=contains(figureargs,'name','ignorecase',true);
                if ~any(nameposition)
                    DisplayError('Tag and Name missing','Specify Tag or Name for figure'), return,
                end
                tag=figureargs{find(nameposition)+1};
                figureargs(numel(figureargs)+1:numel(figureargs)+2,1) = {'Tag',tag};
            else
                tag=figureargs{find(tagposition)+1};
            end
            if isempty(figh)
                if isuifigure
                    figh=findall(groot, 'HandleVisibility', 'off','-and','Tag',strcat(mfigobj.TagBase,mfigobj.spacer,tag));
                else
                    figh=findobj(groot,'Tag',strcat(mfigobj.TagBase,mfigobj.spacer,tag));
                end
            else
                mfigobj.Figure = figh;
                for iar = 1:2:numel(figureargs)
                    propname=figureargs{iar};propname(1)=upper(propname(1));
                    figh.(propname)=figureargs{iar+1};
                end
                mfigobj.Figure.Tag = strcat(mfigobj.TagBase,mfigobj.spacer,tag);
                figh.UserData.mfigobj = mfigobj;
            end
            if isvalid(figh)
                figure2(figh);
                mfigobj = figh.UserData.mfigobj;
            else
                mfigobj.Figure = figure2(figureargs{:},'uifigure',logic2str(isuifigure));
                mfigobj.Figure.Tag = strcat(mfigobj.TagBase,mfigobj.spacer,mfigobj.Figure.Tag);
            end
            mfigobj.Tag = mfigobj.Figure.Tag;
            mfigobj.Figure.UserData.mfigobj = mfigobj;
            mfigobj.Name = mfigobj.Figure.Name;
            mfigobj.FigType = otherargsstruct.figtype;
            mfigobj.Category = otherargsstruct.category;
            if ~isvolatile
                mfigobj.Figure.CloseRequestFcn = @mfigobj.SetFigureInvisible;
            end
            if strcmpi(mfigobj.Tag,mfigobj.MainPanelTag)
                mfigobj.CreateMenuBar;
                mfigobj.CreateMenuSelectFunctions;
            end
        end
        function Save(mfigobj)
            %Save Save figure
            mfigobj.StartWait
            SaveFig(mfigobj.Figure);
            mfigobj.StopWait
        end
        function AddAxesToFigure(mfigobj)
            %Create Axes and Tool objects
            if mfigobj.nAxes~=0
                mfigobj.CreateMenuBar;
                mfigobj.CreateMenuSelectFunctions;
                mfigobj.Figure.KeyPressFcn = @mfigobj.GetKeyboardShortcut;
                mfigobj.Figure.ButtonDownFcn = @mfigobj.ToogleSelect;
                addlistener(mfigobj,'AxesSelection',@mfigobj.UpdateFigureMenu); % Update figure menus checked status
                ah = findobj(mfigobj.Figure,'type','axes');
                mfigobj.Axes = maxes.empty;
                mfigobj.Tools = mtool.empty;
                for iah = 1:mfigobj.nAxes
                    mfigobj.Axes(iah,1) = maxes(ah(iah),mfigobj);
                    mfigobj.Tools(iah,1) = mfigobj.Axes(iah,1).Tool;
                end
            end
        end
        function StartWait(mfigobj)
            %Start wait: changes pointer of figure to circle
            StartWait(mfigobj.Figure)
        end
        function StopWait(mfigobj,varargin)
            %Stop wait: restores pointer of figure
            StopWait(mfigobj.Figure)
        end
        function Restore(mfigobj)
            %Hard reset of figure
            mfigobj.Figure.reset
        end
        function Show(mfigobj,varargin)
            %Shows figure
            if nargin>1
                status = varargin{1};
                mfigobj.Figure.Visible = status;
            else
                figure2(mfigobj.Figure);
            end
        end
        function SetAsCurrentFigure(mfigobj)
            %Set the figure are current
            set(groot,'CurrentFigure',mfigobj.Figure);
        end
        function set.Selected(mfigobj,newdata)
            % Set the selection of figure
            if logical(newdata) == true
                mfigobj.Figure.Color = mfigobj.SelectedColor;
                if mfigobj.nAxes
                    mfigobj.Axes.ToogleSelect('on');
                end
            else
                set(mfigobj.Figure,'Color','default');
                if mfigobj.nAxes
                    mfigobj.Axes.ToogleSelect('off');
                end
            end
        end
        function out = get.Selected(mfigobj)
            % Get the selection of figure
            if all(mfigobj.Figure.Color == mfigobj.SelectedColor)
                out = true;
            else
                out = false;
            end
        end
        function naxes=get.nAxes(mfigobj)
            % Get the number of maxes objs
            naxes=numel(findobj(mfigobj.Figure,'type','image'));
        end
        function ntools=get.nTool(mfigobj)
            % Get the number of mtool objs
            ntools=mfigobj.nAxes;
        end
        ToogleSelect(mfigobj,varargin); %Tool for toogle selection of figure
        function ShowMainPanel(mfigobj,~,~)
            mainpanelmfigobj = mfigobj.GetAllFigs('Tag','MainPanel');
            mainpanelmfigobj.Show;
        end
        function mainpanelmfigobj=GetMainPanel(mfigobj)
            mainpanelmfigobj = mfigobj.GetAllFigs('Tag','MainPanel');
        end
        function Close(mfigobj)
            nmfigobjs = numel(mfigobj);
            for ifig = 1:nmfigobjs
                mfigobj(ifig).Figure.CloseRequestFcn = 'closereq';
                delete(mfigobj(ifig).Figure);
            end
        end
        function Exit(mfigobj,~,~)
            allmfigobjs = mfigobj.GetAllFigs('all');
            allmfigobjs.Close;
            run('.\utilities\Uninstaller.m');
        end
    end
    methods (Access = private)
        CreateMenuBar(mfigobj);
        CreateMenuSelectFunctions(mfigobj);
        %CreateToolTips(mfigobj);
        SelectAllAxes(mfigobj,menuobj,event);  % mixed methods
        UpdateFigureMenu(mfigobj,mfig,event); % mixed methods
        GetKeyboardShortcut(mfigobj,mfig,event) %mixed methods
        function SetFigureInvisible(mfigobj,~,~)
            mfigobj.Figure.Visible = 'off';
        end
        ToolSelection(mfigobj,menuobj,event);  % mixed methods
        [completetoolname,varargout] = GetToolName(mfigobj,menuobj);
    end
    methods (Hidden = true)
        % Methods inherithed by children
        mfigobj = SelectMultipleFigures(mfigobj,menuobj,event,operation);  % mixed methods
        DeselectAll(mfigobj,menuobj,event);  % mixed methods
        function allmfigobjs=GetAllFigs(mfigobj,varargin)
            tag2find = char.empty;
            if nargin>1
                if strcmpi(varargin{1},'tag')
                    tag2find = varargin{2};
                end
            end
            allfigs=findall(groot,'type','figure','-and','-regexp','Tag',strcat(mfigobj.TagBase,mfigobj.spacer,tag2find));
            allmfigobjs=arrayfun(@(ifs)allfigs(ifs).UserData.mfigobj,1:numel(allfigs))';
            if ~isempty(tag2find), return; end
            if nargin>1
                if any(contains(varargin,'all'))
                    return
                end
            end
            allmfigobjs=allmfigobjs(logical(vertcat(allmfigobjs.nAxes)~=0));
        end
    end
end
function [figureargs,otherargsstruc]=parseInputs(argin)
if isrow(argin),argin=argin';end
if ishandle(argin{1})
    if isvalid(argin{1})
        figh=argin(1);
        argin = argin(2:end);
    end
else
    figh = [];
end
tfh=figure('visible','off');
isprops = cellfun(@(genprop) isprop(tfh,genprop),argin(1:2:numel(argin)-1));
delete(tfh);
isprops = repelem(isprops,2);
figureargs = vertcat(figh,argin(isprops));
otherargs = argin(~isprops);
fields={'uifigure','category','figtype','volatile'};
val = {false,'none','side',false};
for ifl = 1:numel(fields)
    otherargsstruc.(fields{ifl}) = val{ifl};
end
for iot = 1:2:numel(otherargs)
    switch lower(otherargs{iot})
        case 'uifigure'
            val = str2logic(otherargs{iot+1});
        case 'figtype'
            val = otherargs{iot+1};
        case 'category'
            val = otherargs{iot+1};
        case 'volatile'
            val = str2logic(otherargs{iot+1});
    end
    otherargsstruc.(lower(otherargs{iot})) = val;
end
end
function logic = str2logic(str)
if strcmpi(str,'true'),logic = true;else, logic = false;end
end
function str = logic2str(logic)
if logic, str = 'true';else, str = 'false';end
end