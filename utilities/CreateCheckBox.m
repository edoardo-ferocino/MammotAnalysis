function Ch=CreateCheckBox(parent,varargin)
   Ch=uicontrol(parent,varargin{:});
   Ch.Style = 'Checkbox';
end