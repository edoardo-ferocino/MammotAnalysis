function Data = ApplyShiftToData(MFH,Data)
if isfield(MFH.UserData,'ApplyShift')
    if strcmpi(MFH.UserData.ProfileOrientation,'horizontal')
        Data(MFH.UserData.ShiftDimIndxs,:,:,:) =...
            circshift(Data(MFH.UserData.ShiftDimIndxs,:,:,:),MFH.UserData.ShiftDimVal,2);
    else
        errordlg('Feature not tested yet','Error');
        return
        Data(:,MFH.UserData.ShiftDimIndxs,:,:) = ...
            circshift(Data(:,MFH.UserData.ShiftDimIndxs,:,:),MFH.UserData.ShiftDimVal,1);
    end
end

