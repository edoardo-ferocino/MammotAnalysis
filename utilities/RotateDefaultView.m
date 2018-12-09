function RotateDefaultView(src,event,axh)
if ~isfield(src.UserData,'ActualOrientation')
    src.UserData.ActualOrientation = 0;
end
src.UserData.ActualOrientation = src.UserData.ActualOrientation+90;
[az,~]=view(axh,src.UserData.ActualOrientation,90);

end