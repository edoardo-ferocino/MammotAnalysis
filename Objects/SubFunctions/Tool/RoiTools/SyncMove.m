function SyncMove(triggerroi,~,allroiobjs)
for ir = 1:numel(allroiobjs)
    allroiobjs(ir).Shape.Position =  triggerroi.Shape.Position;
    allroiobjs(ir).GetData(allroiobjs(ir).Shape,[],allroiobjs(ir).Tool.Axes,false);
end
end