function FH=CreateOrFindFig(Name,varargin)
LookForVarargin = varargin;
ActualVarArgin = varargin;

LogicalIndexes = repmat(~contains(LookForVarargin(1:2:end),{'position'},'IgnoreCase',true),2,1);
LookForVarargin=LookForVarargin(LogicalIndexes(:));

LogicalIndexesUiFigure = repmat(~contains(LookForVarargin(1:2:end),{'uifigure'},'IgnoreCase',true),2,1);
LogicalIndexesUiFigureActualVarargin = repmat(~contains(varargin(1:2:end),{'uifigure'},'IgnoreCase',true),2,1);

isUIFigPos=find(LogicalIndexesUiFigure(:)==0,1,'last');
if isempty(isUIFigPos)
    isUIFig = false;
else
    isUIFig = LookForVarargin{isUIFigPos};
end
LookForVarargin=LookForVarargin(LogicalIndexesUiFigure(:));
ActualVarArgin = ActualVarArgin(LogicalIndexesUiFigureActualVarargin(:));

if isUIFig
    FH=findall(groot, 'HandleVisibility', 'off','-and','Name',Name,'-and',LookForVarargin{:});
else
    FH = findobj(groot,'Type','figure','-and','Name',Name,'-and',LookForVarargin{:});
end
if ~isempty(FH)
    figure(FH);
else
    if isUIFig
        FH = uifigure('Name',Name,ActualVarArgin{:});
    else
        FH = figure('Name',Name,ActualVarArgin{:});
    end
    FH.UserData.isFFS = any(contains(LookForVarargin,{'maximized'},'IgnoreCase',true));
end
end