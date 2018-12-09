function GetActualOrientationAction(MFH,Variable,VariableName)
if isfield(MFH.UserData.RotateDefaultView.UserData,'ActualOrientation')
    flipdir = rem(fix(MFH.UserData.RotateDefaultView.UserData.ActualOrientation/90),4);
else
    flipdir = 0;
end
switch flipdir
    case 0
        %VariableName=VariableName;
        MFH.UserData.ProfileOrientation = 'horizontal';
    case 1
        Variable = flip(permute(Variable,[2 1 3 4]),2);
        MFH.UserData.ProfileOrientation = 'vertical';
    case 2
        Variable = flip(flip(Variable,1),2);
        MFH.UserData.ProfileOrientation = 'horizontal';
    case 3
        Variable = flip(permute(Variable,[2 1 3 4]),1);
        MFH.UserData.ProfileOrientation = 'vertical';
end
assignin('caller',VariableName,Variable)
return
switch flipdir
    case 0
        action = [NewVar '=' VariableName ';'];
        MFH.UserData.ProfileOrientation = 'horizontal';
    case 1
        action = [NewVar ' = flip(permute(' VariableName ',[2 1 3 4]),2);'];
        MFH.UserData.ProfileOrientation = 'vertical';
    case 2
        action = [NewVar '= flip(flip(' VariableName ',1),2);'];
        MFH.UserData.ProfileOrientation = 'horizontal';
    case 3
        action = [NewVar '= flip(permute(' VariableName ',[2 1 3 4]),1);'];
        MFH.UserData.ProfileOrientation = 'vertical';
end

end