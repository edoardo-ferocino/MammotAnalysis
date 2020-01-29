function [message,allcopiedroiobjs] = PasteRoi(mtoolobj)
allmfigobjs = mtoolobj.Parent.GetAllFigs;
alltoolobjs = vertcat(allmfigobjs.Tools);
allroiobjs = vertcat(alltoolobjs.Roi);
alliscopiedrois = vertcat(allroiobjs.CopiedRoi);
allcopiedshapes = vertcat(allroiobjs(alliscopiedrois).Shape);
allcopiedroiobjs=allroiobjs(alliscopiedrois);
for is = 1:numel(allcopiedshapes)
    shapeobj=allcopiedshapes(is);shapetype=split(shapeobj.Type,'.');shapetype=shapetype{3};
    ApplyShape(mtoolobj,shapetype,allcopiedroiobjs(is).Type,allcopiedshapes(is));
end
allcopiedroiobjs=allroiobjs(alliscopiedrois);
message = ['Pasted Roi ',num2str([allroiobjs(alliscopiedrois).ID],'%d,')];message(end)=[];
end