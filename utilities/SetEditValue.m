function SetEditValue(src,~,type,MFH)
switch type
    case 'numgate'
        MFH.UserData.NumGate.UserData.NumGate = ...
            str2double(src.String);
    case 'fractfirst'
        MFH.UserData.FractFirst.UserData.FractFirst = ...
            str2double(src.String);
    case 'fractlast'
        MFH.UserData.FractLast.UserData.FractLast = ...
            str2double(src.String);
end
end
