function AddFillBlackLines(parentfigure,object2attach,Wave,MFH)
PercFract = 95;
Threshold1 = 500000;

if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
mmh = uimenu(cmh,'Text','Fill black lines','Callback',@FillBlackLines);

    function FillBlackLines(~,~)
        % Filling black lines
        Data = object2attach.CData;
        [yzeros, xzeros] = find(Data<Threshold1);
        numZeros = numel(xzeros);
        for iz = 1:numZeros
            if yzeros(iz) == 1 && Data(yzeros(iz)+1,xzeros(iz))>Threshold1
                Data(yzeros(iz),xzeros(iz)) = Data(yzeros(iz)+1,xzeros(iz));
            end
            if yzeros(iz) ~= 1 && yzeros(iz) ~= size(Data,1) && Data(yzeros(iz)+1,xzeros(iz))>Threshold1 && Data(yzeros(iz)-1,xzeros(iz))>Threshold1
                Data(yzeros(iz),xzeros(iz)) = mean([Data(yzeros(iz)+1,xzeros(iz)) Data(yzeros(iz)-1,xzeros(iz))]);
            end
            object2attach.CData = Data;
        end
    end
end