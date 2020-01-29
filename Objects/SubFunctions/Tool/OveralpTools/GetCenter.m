function [X,Y] = GetCenter(data)
fig=figure('WindowState','maximized');           	
imagesc(data);
axis image; axis on; colormap gray; 
title('Select the center of the scan and press ENTER');
[YC,XC] = getpts(fig);
Y=round(YC);
X=round(XC);
close(fig);