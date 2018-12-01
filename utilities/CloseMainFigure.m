function CloseMainFigure(src,event)
H = guidata(gcbo);
if isfield(H,'FH')
    FH = H.FH;
    for ifigs = 1:numel(FH)
        FH(ifigs).CloseRequestFcn = 'closereq';
        delete(FH(ifigs))
    end
end
delete(src)
end