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
end