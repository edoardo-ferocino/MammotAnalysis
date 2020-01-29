function ToogleSelect(maxesobj,varargin)
% Axes selection tool
ImposeStatus = false;
status = 'nan';
selectrois = true;
if ~isempty(varargin)
    if ~isobject(varargin{1})
        ImposeStatus = true;
        status = varargin{1};
    elseif strcmpi(maxesobj.Parent.Figure.SelectionType,'alt')
        selectrois = true;
    else
       selectrois = false; 
    end
end
for iobj = 1:numel(maxesobj)
    maxesactvobj = maxesobj(iobj);
    if strcmpi(maxesactvobj.Image.Selected,'on')&&~ImposeStatus||(ImposeStatus&&strcmpi(status,'off'))
        maxesactvobj.Image.Selected = 'off';
        set(maxesactvobj.axes,'XColor','default');
        set(maxesactvobj.axes,'YColor','default');
        if selectrois
            for ir = 1:maxesactvobj.Tool.nRoi
                maxesactvobj.Tool.Roi(ir).Selected = false;
            end
        end
    elseif strcmpi(maxesactvobj.Image.Selected,'off')&&~ImposeStatus||(ImposeStatus&&strcmpi(status,'on'))
        maxesactvobj.Image.Selected = 'on';
        maxesactvobj.axes.XColor = 'red';
        maxesactvobj.axes.YColor = 'red';
        if selectrois
            for ir = 1:maxesactvobj.Tool.nRoi
                maxesactvobj.Tool.Roi(ir).Selected = true;
            end
        end
    end
end
notify(maxesobj(1).Parent,'AxesSelection');
end