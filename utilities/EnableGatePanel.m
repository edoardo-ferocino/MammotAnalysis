function EnableGatePanel(src,~,MFH)
if src.Value
    Visible = 'on';
else
    Visible = 'off';
end
MFH.UserData.GateContainer.Visible = Visible;
MFH.UserData.SelectReferenceArea.Visible = Visible;
end