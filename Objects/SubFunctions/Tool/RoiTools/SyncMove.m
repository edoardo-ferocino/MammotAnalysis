function SyncMove(triggerroi,~,allroiobjs)
for ir = 1:numel(allroiobjs)
    allroiobjs(ir).Shape.Position =  triggerroi.Shape.Position;
end
end