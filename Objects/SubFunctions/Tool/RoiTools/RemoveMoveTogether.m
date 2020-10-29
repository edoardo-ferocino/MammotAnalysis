function message = RemoveMoveTogether(mtoolobj)
for ir=1:mtoolobj.nRoi
    if mtoolobj.Roi(ir).Selected
        if ~isempty(mtoolobj.Roi(ir).SyncRoiMoveListenerHandle)
            if isvalid(mtoolobj.Roi(ir).SyncRoiMoveListenerHandle)
                if mtoolobj.Roi(ir).SyncRoiMoveListenerHandle.Enabled
                    mtoolobj.Roi(ir).SyncRoiMoveListenerHandle.Enabled = false;
                    mtoolobj.Roi(ir).SyncRoiMoveListenerHandle.delete;
                end
            end
        end
        mtoolobj.Roi(ir).Selected = false;
    end
end
mtoolobj.Axes.ToogleSelect('off');
message = 'Removed move together rois';

end