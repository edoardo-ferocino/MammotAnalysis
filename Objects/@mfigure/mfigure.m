classdef mfigure < handle
    %mfigure Figure Class for the MammotAnalysis interface
    events
        AxesSelection           %event triggered by axes selection. Cause the update of the figure menu status
    end
    properties
        Figure;                 %figure
        Category;               %category of figure (spectral,counts...)
        Name;                   %figure name
        Axes maxes;             %axes object handle (one for each axes)
        Tools mtool;            %tool object handle (one for each axes)
        Graphical;              %general graphical handles
        Data;                   %similar to UserData
    end
    properties (SetAccess = immutable)
        Tag;                    %figure tag. Unique identifier
    end
    properties (Constant = true,Hidden = true)
        spacer = '%';           %spacer for toolnames
        TagBase = 'mfigure';    %tag base name
        SelectedColor = [1 0.87 0.87];  %color for selection
        MainPanelTag = strcat('mfigure%MainPanel'); %identifier for main panel
    end
    properties (Constant)
        Wavelengths = [635 680 785 905 933 975 1060]';
    end
    properties (Hidden = true)
        nMenu=0;                  %numel total menus
        nMainMenu=0;              %numel main menus
        nSubMenu=0;               %numel sub menus
        nAxes=0;                  %numel axes
        nTool=0;                  %numel tool objects
        Menu;                     %figure menus handle
        MainMenu;                 %main menus handle
        SubMenu;                  %submenus handle
        ScaleFactor;              %factor from pixel to mm
    end
    properties (Dependent)
        Selected;               %figure is selected for multiple apply of tools (or shortcut for selecting all axes of a figure)
    end
    properties (Dependent,Hidden = true)
        StrictSelected
    end
    methods
        function mfigobj = mfigure(varargin)
            %Object creator
            global MPFOBJ;
            [figureargs,otherargsstruct]=parseInputs(varargin);
            isuifigure=otherargsstruct.uifigure;
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
                    figh=findall(groot,'HandleVisibility', 'off','-and','Tag',strcat(mfigobj.TagBase,mfigobj.spacer,tag));
                else
                    figh=findobj('Tag',strcat(mfigobj.TagBase,mfigobj.spacer,tag));
                end
            else
                mfigobj.Figure = figh;
                for iar = 1:2:numel(figureargs)
                    propname=figureargs{iar};propname(1)=upper(propname(1));
                    figh.(propname)=figureargs{iar+1};
                end
                mfigobj.Figure.Tag = strcat(mfigobj.TagBase,mfigobj.spacer,tag);
                mfigobj.Tag = mfigobj.Figure.Tag;
                mfigobj.AddFigObj(mfigobj);
            end
            if isvalid(figh)
                figure2(figh);
                mfigobj = mfigobj.GetFigObj(figh);
            else
                mfigobj.Figure = figure2(figureargs{:},'uifigure',logic2str(isuifigure));
                mfigobj.Figure.Tag = strcat(mfigobj.TagBase,mfigobj.spacer,mfigobj.Figure.Tag);
            end
            mfigobj.Tag = mfigobj.Figure.Tag;
            mfigobj.Name = mfigobj.Figure.Name;
            mfigobj.Category = otherargsstruct.category;
            mfigobj.Data.Category = mfigobj.Category;
            mfigobj.Figure.CloseRequestFcn = @ClReq;
            if strcmpi(mfigobj.Tag,mfigobj.MainPanelTag)
                mfigobj.CreateMenuBar;
                mfigobj.CreateMenuSelectFunctions;
                MPFOBJ = mfigobj;
            end
            mfigobj.Graphical.MultiSelFigPanel = findobj(mfigobj.Figure,'Tag',...
                    strcat(mfigobj.Tag,mfigobj.spacer,'MultiFigPanel'));
            if isempty(mfigobj.Graphical.MultiSelFigPanel)
                mfigobj.Graphical.MultiSelFigPanel=uipanel(mfigobj.Figure,'BorderType','none','Position',[0.97 0.97 0.03 0.03],...
                    'tag',strcat(mfigobj.Tag,mfigobj.spacer,'MultiFigPanel'));
            end
            mfigobj.Graphical.MultiSelAxPanel = findobj(mfigobj.Figure,'Tag',...
                    strcat(mfigobj.Tag,mfigobj.spacer,'MultiAxPanel'));
            if isempty(mfigobj.Graphical.MultiSelAxPanel)
                mfigobj.Graphical.MultiSelAxPanel=uipanel(mfigobj.Figure,'BorderType','none','Position',[0 0.97 0.03 0.03],...
                    'tag',strcat(mfigobj.Tag,mfigobj.spacer,'MultiAxPanel'));
            end
            
            if isfield(MPFOBJ.Graphical,'Pixel2mm')
                mfigobj.ScaleFactor = str2double(MPFOBJ.Graphical.Pixel2mm.String);
            end
            mfigobj.AddFigObj(mfigobj);
        end
        function Save(mfigobj,~,~)
            %Save Save figure
            mfigobj.StartWait
            SaveFig(mfigobj);
            mfigobj.StopWait
        end
        function Load(mfigobj,~,~)
            %Save Save figure
            mfigobj.StartWait
            LoadFig;
            mfigobj.StopWait
        end
        
        
        function AddAxesToFigure(mfigobj)
            %Create Axes and Tool objects
            ah = findobj(mfigobj.Figure,'type','axes');
            if numel(ah)~=0
                mfigobj.CreateMenuBar;
                mfigobj.CreateMenuSelectFunctions;
                dch=datacursormode(mfigobj.Figure);
                dch.removeAllDataCursors;
                dch.Enable = 'off';
                mfigobj.Figure.KeyPressFcn = @mfigobj.GetKeyboardShortcut;
                mfigobj.Figure.ToolBar = 'figure';
                mfigobj.Figure.ButtonDownFcn = @mfigobj.ToogleSelect;
                addlistener(mfigobj,'AxesSelection',@mfigobj.UpdateFigureMenu); % Update figure menus checked status
                mfigobj.Axes = maxes.empty;
                mfigobj.Tools = mtool.empty;
                mfigobj.nAxes = numel(ah);
                mfigobj.nTool = numel(ah);
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
        function Show(mfigobj)
            %Shows figure
            figure2(mfigobj.Figure);
        end
        function Hide(mfigobj)
            mfigobj.Figure.Visible = 'off';
        end
        function set.StrictSelected(mfigobj,newdata)
            % Set the selection of figure
            if logical(newdata) == true
                mfigobj.Figure.Color = mfigobj.SelectedColor;
                if mfigobj.nTool
                    mfigobj.Axes.ToogleSelect('on');
                end
            else
                set(mfigobj.Figure,'Color','default');
                if mfigobj.nTool
                    mfigobj.Axes.ToogleSelect('off');
                end
            end
        end
        function set.Selected(mfigobj,newdata)
            % Set the selection of figure
            mfigobj.StrictSelected = newdata;
            mfigobj.UpdateMultiSelect
        end
        function out = get.Selected(mfigobj)
            % Get the selection of figure
            if all(mfigobj.Figure.Color == mfigobj.SelectedColor)
                out = true;
            else
                out = false;
            end
        end
        ToogleSelect(mfigobj,varargin); %Tool for toogle selection of figure
        function ShowMainPanel(mfigobj,~,~)
            MPOBJ = mfigobj.GetMainPanel;
            MPOBJ.Show;
        end
        function Close(mfigobj)
            nmfigobjs = numel(mfigobj);
            for ifig = 1:nmfigobjs
                mfigobj(ifig).Figure.CloseRequestFcn = 'closereq';
                delete(mfigobj(ifig).Figure);
            end
        end
        function Exit(mfigobj,~,~)
            MPOBJ=mfigobj.GetMainPanel;
            sett = {'FractFirst' 'FractLast' 'BkgFirst' 'BkgLast' 'NumGates' 'Pixel2mm'}';
            val = cellfun(@(is) num2cell(str2double(MPOBJ.Graphical.(is).String)),sett);
            Sett = cell2struct(val,sett);
            save('.\Settings\sett.mat','Sett');
            allmfigobjs = mfigobj.GetAllFigs('all');
            allmfigobjs.Close;
            run('.\utilities\Uninstaller.m');
            evalin('base','clear ''MainPanel''');
        end
    end
    methods (Static)
        function MPOBJ=GetMainPanel
            global MPFOBJ
            MPOBJ = MPFOBJ;
        end
    end
    methods (Access = private)
        CreateMenuBar(mfigobj);
        CreateMenuSelectFunctions(mfigobj);
        SelectAllAxes(mfigobj,menuobj,event);  % mixed methods
        UpdateFigureMenu(mfigobj,mfig,event); % mixed methods
        ToolSelection(mfigobj,menuobj,event);  % mixed methods
        [completetoolname,varargout] = GetToolName(mfigobj,menuobj);
        function HideFig(mfigobj,~,~)
            mfigobj.Hide;
        end
    end
    methods (Hidden = true)
        % Methods inherithed by children
        function UpdateMultiSelect(mfigobj)
            allfigsobjs = mfigobj.GetAllFigs;
            if sum(vertcat(allfigsobjs.Selected))>1
                for ifigs = 1:numel(allfigsobjs)
                    allfigsobjs(ifigs).Graphical.MultiSelFigPanel.BackgroundColor = 'yellow';
                    allfigsobjs(ifigs).Graphical.MultiSelFigPanel.Title = num2str(sum(vertcat(allfigsobjs.Selected)));
                end
            else
                for ifigs = 1:numel(allfigsobjs)
                    allfigsobjs(ifigs).Graphical.MultiSelFigPanel.BackgroundColor=allfigsobjs(ifigs).Figure.Color;
                    allfigsobjs(ifigs).Graphical.MultiSelFigPanel.Title = char.empty;
                end
            end
        end
        mfigobj = SelectMultipleFigures(mfigobj,menuobj,event,operation,figurename);  % mixed methods
        DeselectAll(mfigobj,menuobj,event);  % mixed methods
        function AddFigObj(~,newobj)
            global MPFOBJ
            if ~isfield(MPFOBJ.Graphical,'allmfigobjs')
                MPFOBJ.Graphical.allmfigobjs = newobj;
            else
                nfig = numel(MPFOBJ.Graphical.allmfigobjs);
                isfigpresent = arrayfun(@(ifig)strcmp(MPFOBJ.Graphical.allmfigobjs(ifig).Tag,newobj.Tag),1:nfig);
                if any(isfigpresent)
                    MPFOBJ.Graphical.allmfigobjs(isfigpresent) = newobj;
                else
                    MPFOBJ.Graphical.allmfigobjs(end+1) = newobj;
                end
            end
        end
        function mfigobj = GetFigObj(mfigobj,figh)
            MPFOBJ = mfigobj.GetMainPanel;
            FigObjList = MPFOBJ.Graphical.allmfigobjs;
            nfig = numel(FigObjList);
            isfigpresent = arrayfun(@(ifig)strcmp(FigObjList(ifig).Tag,figh.Tag),1:nfig);
            mfigobj = FigObjList(isfigpresent);
        end
        function allmfigobjs=GetAllFigs(mfigobj,varargin)
            MPOBJ = mfigobj.GetMainPanel;
            allmfigobjs = MPOBJ.Graphical.allmfigobjs;
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
fields={'uifigure','category'};
val = {false,'none'};
for ifl = 1:numel(fields)
    otherargsstruc.(fields{ifl}) = val{ifl};
end
for iot = 1:2:numel(otherargs)
    switch lower(otherargs{iot})
        case 'uifigure'
            val = str2logic(otherargs{iot+1});
        case 'category'
            val = otherargs{iot+1};
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
function ClReq(figh,~,~)
figh.Visible = 'off';
end
