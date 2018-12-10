function CreateDefaultView(src,~,~)
 X = src.XAxis.Limits(1):0.01:src.XAxis.Limits(2);
 Y = X.^2 - X +0.25;
 fill(X,Y,[1.0000    0.7882    0.7608],'EdgeColor',[1.0000    0.7882    0.7608])
 text(src,0.85,0.2,'DX')
 text(src,0.15,0.2,'SX')
 %area(src,X,Y,'FaceColor',[1.0000    0.7882    0.7608],'EdgeColor',[1.0000    0.7882    0.7608]);
 src.XTick = [];src.YTick = [];
end