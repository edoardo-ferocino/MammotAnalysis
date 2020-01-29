% [EDITED, 2018-06-05, typos fixed]
function FigHandle = figure2(varargin)
[figureargs,otherargs]=parseInputs(varargin);
isuifigure = otherargs.uifigure;
if any(ishandle(figureargs{1}))||any(isnumeric(figureargs{1})), isuifigure = 0; end
MP = get(0, 'MonitorPositions');
if size(MP, 1) == 1  % Single monitor
    if isuifigure
        FigH = uifigure(figureargs{:});
    else
        FigH = figure(figureargs{:});
    end
else                 % Multiple monitors
    % Catch creation of figure with disabled visibility:
    indexVisible = find(strncmpi(figureargs(1:2:end), 'Vis', 3));
    if ~isempty(indexVisible)
        paramVisible = figureargs(indexVisible(end) + 1);
    else
        paramVisible = get(0, 'DefaultFigureVisible');
    end
    %
    Shift = MP(2, 1:2);
    try
        if isuifigure
            FigH = uifigure(figureargs{:});
        else
            FigH = figure(figureargs{:});
        end
    catch ME
        throwAsCaller(ME)
    end
    if ~any(ishandle(figureargs{1}))&&~any(isnumeric(figureargs{1}))
        set(FigH, 'Units', 'pixels');
        pos      = get(FigH, 'Position');
        set(FigH, 'Position', [pos(1:2) + Shift, pos(3:4)], ...
            'Visible', paramVisible);
    end
end
if nargout ~= 0
    FigHandle = FigH;
end

end

function [figureargs,otherargsstruc]=parseInputs(argin)
figureargs = cell.empty;
if ishandle(argin{1})
  figureargs{numel(figureargs)+1} = argin{1};
  argin = argin(2:end);
elseif isnumeric(argin{1})
  figureargs{numel(figureargs)+1} = argin{1};  
  argin = argin(2:end);
end
tfh=figure('visible','off');
isprops = cellfun(@(genprop) isprop(tfh,genprop),argin(1:2:numel(argin)-1));
delete(tfh);
isprops = repelem(isprops,2);
nfigargs = numel(argin(isprops));
nactfigargs = numel(figureargs);
figureargs(nactfigargs+1:nactfigargs+nfigargs) = argin(isprops);
otherargs = argin(~isprops);
fields={'uifigure'};
val = {false};
for ifl = 1:numel(fields)
    otherargsstruc.(fields{ifl}) = val{ifl};
end
for iot = 1:2:numel(otherargs)
    switch lower(otherargs{iot})
        case 'uifigure'
            val = str2logic(otherargs{iot+1});
    end
    otherargsstruc.(lower(otherargs{iot})) = val;
end
end
function str = str2logic(str)
if strcmpi(str,'true'),str = true;else, str = false;end
end