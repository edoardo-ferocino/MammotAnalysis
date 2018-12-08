function Wave = ApplyGates(ReferenceS,Data,MFH)
numwave = numel(ReferenceS);
numgate = str2double(MFH.UserData.NumGate.String);
for iw = 1:numwave
    Wave(iw).Data = Data(:,:,ReferenceS(iw).Roi); %#ok<*AGROW>
    for ig = 1:numgate
        Wave(iw).Gate(ig).TemporalInterval = ReferenceS(iw).Gate(ig).TemporalInterval;
        Wave(iw).Gate(ig).Roi = ReferenceS(iw).Gate(ig).Roi;
        Wave(iw).Gate(ig).Counts = sum(Wave(iw).Data(:,:,Wave(iw).Gate(ig).Roi),3);
    end
end
end