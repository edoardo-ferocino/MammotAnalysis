function ToogleSelect(mfigobj,varargin)
% Axes selection tool
ImposeStatus = false;
status = 'nan';
if nargin>1
    if ~isobject(varargin{1})
        ImposeStatus = true;
        status = varargin{1};
    end
end
for iobj = 1:numel(mfigobj)
    mfigactvobj = mfigobj(iobj);
    if mfigactvobj.Selected&&~ImposeStatus||(ImposeStatus&&strcmpi(status,'off'))
        mfigactvobj.Selected = false;
    elseif mfigactvobj.Selected==0&&~ImposeStatus||(ImposeStatus&&strcmpi(status,'on'))
        mfigactvobj.Selected = true;
    end
end
allfigsobjs = mfigobj.GetAllFigs;
if sum(vertcat(allfigsobjs.Selected))>1
    for ifigs = 1:numel(allfigsobjs)
        allfigsobjs(ifigs).OtherFiguresSelectedH.BackgroundColor = 'yellow';
        allfigsobjs(ifigs).OtherFiguresSelectedH.Title = num2str(sum(vertcat(allfigsobjs.Selected)));
    end
else
    for ifigs = 1:numel(allfigsobjs)
        allfigsobjs(ifigs).OtherFiguresSelectedH.BackgroundColor=allfigsobjs(ifigs).Figure.Color;
        allfigsobjs(ifigs).OtherFiguresSelectedH.Title = char.empty;
    end
end
end