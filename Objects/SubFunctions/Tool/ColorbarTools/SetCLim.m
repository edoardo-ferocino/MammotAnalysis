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
maxesobj.CLim = CLim;
if strcmpi(link,'link')
    for ia = 1:numel(actualmaxesobjs)
        actualmaxesobjs(ia).CLim = maxesobj.CLim; 
        dch=findobj('Tag',strcat(actualmaxesobjs(ia).Parent.Tag,actualmaxesobjs(ia).Name,'down'));
        uch=findobj('Tag',strcat(actualmaxesobjs(ia).Parent.Tag,actualmaxesobjs(ia).Name,'up'));
        dch.String = num2str(CLim(1));
        uch.String = num2str(CLim(2));
    end
end
end