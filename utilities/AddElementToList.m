function AddElementToList(List,Element)
    List.String{end+1} = Element.Name;
    if ~isfield(List.UserData,'Element')
       List.Element(1) = Element;
    else
       List.Element(end+1) = Element;
    end
end