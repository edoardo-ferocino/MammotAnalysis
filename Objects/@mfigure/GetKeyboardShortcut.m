function GetKeyboardShortcut(mfigobj,~,~)
% Respond to pressing of the keyboard

if ~isnan(str2double(mfigobj.Figure.CurrentCharacter))
    selectedaxes = str2double(mfigobj.Figure.CurrentCharacter);
    if selectedaxes<=mfigobj.nAxes
        mfigobj.Axes(selectedaxes).ToogleSelect;
    end
elseif ischar(mfigobj.Figure.CurrentCharacter)
    character = mfigobj.Figure.CurrentCharacter;
    if strcmpi(character,'f')
        mfigobj.ToogleSelect;
    end
end
end