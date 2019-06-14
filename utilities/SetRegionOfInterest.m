function cut = SetRegionOfInterest(tdata)
fig=figure;
imagesc(tdata); grid on;
axis image; axis on; colormap gray;
title('Zoom on the Region of Interest'); % Selezione della regione di interesse

Pbh=CreatePushButton(fig,'units','normalized','position',[0 0 0.1 0.1],'String','Rotate','Callback',{@RotateIm});
Pbh=CreatePushButton(fig,'units','normalized','position',[0.1 0 0.1 0.1],'String','Get Rect','Callback',{@GetRect});
    function GetRect(~,~)
        rect = drawrectangle(gca);
        nc=sum(sum(rect.createMask,1)~=0);
        nr=sum(sum(rect.createMask,2)~=0);
        cut = reshape(tdata(rect.createMask),nr,nc);
        close(fig);
    end
    function RotateIm(~,~)
        tdata = imrotate(tdata,90);
        imshow(tdata);
    end
waitfor(fig);
end