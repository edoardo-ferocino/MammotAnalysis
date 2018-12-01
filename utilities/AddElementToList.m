function AddElementToList(List,Element)
    List.String{end+1} = Element.Name;
    if isempty(List.UserData)
       List.UserData(1) = Element;
    else
       List.UserData(end+1) = Element;
    end
end