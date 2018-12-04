function AddElementToList(List,Element)
    List.String{end+1} = Element.Name;
    if ~isfield(List.UserData,'Element')
       List.UserData.Element(1) = Element;
    else
       List.UserData.Element(end+1) = Element;
    end
end