function cut = SetRegionOfInterest(tdata)
fig=figure;
imagesc(tdata); grid on;
axis image; axis on; colormap gray;
title('Zoom on the Region of Interest'); % Selezione della regione di interesse

Pbh=CreatePushButton(fig,'units','normalized','position',[0 0 0.1 0.1],'String','Rotate','Callback',{@RotateIm,tdata});
Pbh=CreatePushButton(fig,'units','normalized','position',[0.1 0 0.1 0.1],'String','Get Rect','Callback',{@GetRect});
    function GetRect(~,~)
        rect = drawrectangle(gca);
        nc=sum(sum(rect.createMask,1)~=0);
        nr=sum(sum(rect.createMask,2)~=0);
        cut = reshape(tdata(rect.createMask),nr,nc);
        close(fig);
        return
        rect = getrect(fig);
        [xmin,ymin,Lx,Ly] = deal(floor(rect(1)), floor(rect(2)), floor(rect(3)), floor(rect(4))) ;
        xmin = max (xmin ,1);
        ymin = max (ymin, 1);
        xmax = min(xmin + Lx,size(tdata,2));
        ymax = min(ymin + Ly,size(tdata,1));
        cut=(tdata(ymin:ymax,xmin:xmax));
        close(fig);
    end
    function RotateIm(src,~,Im)
        Im = imrotate(Im,90);
        tdata = Im;
        axes(findobj(src,'type','axes'));
        imshow(Im);
    end
waitfor(fig);
end