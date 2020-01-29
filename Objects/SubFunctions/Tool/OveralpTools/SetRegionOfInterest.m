function cut = SetRegionOfInterest(tdata)
fig=figure('WindowState','maximized');
imagesc(tdata);
axis image; colormap gray;
title('Zoom on the Region of Interest'); % Selezione della regione di interesse

uicontrol(fig,'Style','pushbutton','units','normalized','position',[0 0 0.1 0.1],'String','Rotate','Callback',{@RotateIm});
uicontrol(fig,'Style','pushbutton','units','normalized','position',[0.1 0 0.1 0.1],'String','Get Rect','Callback',{@GetRect});
uicontrol(fig,'Style','pushbutton','units','normalized','position',[0.2 0 0.1 0.1],'String','Go','Callback',{@Go});
    function GetRect(~,~)
        rect = drawrectangle(gca);
        nc=sum(sum(rect.createMask,1)~=0);
        nr=sum(sum(rect.createMask,2)~=0);
        cut = reshape(tdata(rect.createMask),nr,nc);
    end
    function Go(~,~)
        close(fig);
    end
    function RotateIm(~,~)
        tdata = imrotate(tdata,90);
        imshow(tdata);
    end
waitfor(fig);
end