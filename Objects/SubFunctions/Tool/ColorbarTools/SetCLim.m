function SetCLim(editobj,~,maxesobj,side,varargin)
link = 'off';actualmaxesobjs = maxesobj.empty;
if nargin>4
   link = varargin{1}; 
   actualmaxesobjs = varargin{2}; 
end
CLim=maxesobj.CLim;
if strcmpi(side,'up')
    CLim(2) = str2double(editobj.String);
else
    CLim(1) = str2double(editobj.String);
end
if CLim(2) < CLim(1)
    DisplayError('The low limit can''be higher than the higher','Change the limits');
    return
end
maxesobj.CLim = CLim;
if strcmpi(link,'link')
    for ia = 1:numel(actualmaxesobjs)
        actualmaxesobjs(ia).CLim = maxesobj.CLim;
        dch = maxesobj.Graphical.dch;
        uch = maxesobj.Graphical.uch;
        dch.String = num2str(CLim(1));
        uch.String = num2str(CLim(2));
    end
end
end