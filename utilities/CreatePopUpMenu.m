function Ch = CreatePopUpMenu(parent,varargin)
   Ch=uicontrol(parent,varargin{:});
   Ch.Style = 'popupmenu';
end