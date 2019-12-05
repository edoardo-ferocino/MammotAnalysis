addpath(genpath('../utilities'));
cd('../')
TempPath = getapplicationdatadir(fullfile('\Temp'),false,true);
TempFile = fullfile(TempPath,'tempmatlab.mat');
if exist(TempFile,'file')
    delete(TempFile)
end
all_figs = findobj(0, 'type', 'figure');
except = findobj(0,'type','figure','Name','Main panel');
delete(setdiff(all_figs, except));
clearvars
clc
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame')
warning('off','MATLAB:ui:javaframe:PropertyToBeRemoved');
javaFrame = get(gcf,'JavaFrame');
javaFrame.setFigureIcon(javax.swing.ImageIcon(fullfile(pwd,'utilities','Logo.PNG')));
warning('on','MATLAB:ui:javaframe:PropertyToBeRemoved');
warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame')
clear javaFrame