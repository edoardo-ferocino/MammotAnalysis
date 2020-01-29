function message = MoveTogether(mtoolobj,allmtoolobj)
AllRoiObjs = mroi.empty;
for ir = 1:numel(allmtoolobj)
    if isempty(allmtoolobj(ir).Roi), continue; end
    roiselected = vertcat(allmtoolobj(ir).Roi.Selected);
    if sum(roiselected)==0, roiselected = ones(size(roiselected));end
    Roi = allmtoolobj(ir).Roi(roiselected);
    AllRoiObjs = [AllRoiObjs;Roi]; %#ok<AGROW>
end
for isr = 1:mtoolobj.nRoi
    if mtoolobj.Roi(isr).Selected
        roiobj=mtoolobj.Roi(isr);
        roiobj.SyncRoiMoveListenerHandle = addlistener(roiobj,'SyncronousRoiMovement',@(src,event)SyncMove(src,event,AllRoiObjs));
    end
end
message = 'Added listener for sync movement';
end