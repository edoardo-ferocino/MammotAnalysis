function Ch=CreateListBox(parent,varargin)
   Ch=uicontrol(parent,varargin{:});
   Ch.Style = 'listbox';
   Ch.UIContextMenu = uicontextmenu(ancestor(parent,'figure'));
   Ch.UserData.InfoCtxMH = CreateInfoUIContextMenu(Ch.UIContextMenu);
end