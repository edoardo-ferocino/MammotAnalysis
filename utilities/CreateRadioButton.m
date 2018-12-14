function Ch=CreateRadioButton(parent,varargin)
   Ch=uicontrol(parent,varargin{:});
   Ch.Style = 'radiobutton';
end