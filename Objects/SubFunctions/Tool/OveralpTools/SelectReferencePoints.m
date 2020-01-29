function [pixels_per_mm] = SelectReferencePoints(data)
fig=figure('WindowState','maximized');           	
imagesc(data);
axis image; colormap gray; 
title('Select two point at known distance and press ENTER');
[X,Y] = getpts(fig);
temp = inputdlg('Insert the distance in cm'); 
dist_real = str2double(temp{1});
% dist_pixels = sqrt((X(1) - X(2))^2+(Y(1) - Y(2))^2);
dist_pixels = sqrt((X(1) - X(2))^2);
pixels_per_mm = dist_pixels/(10*dist_real);
close(fig);
