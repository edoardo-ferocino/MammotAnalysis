function Ch=CreateListBox(parent,varargin)
   Ch=uicontrol(parent,varargin{:});
   Ch.Style = 'listbox';
end