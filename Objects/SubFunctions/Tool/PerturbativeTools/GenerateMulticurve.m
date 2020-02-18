function message = GenerateMulticurve(mtoolobj)
[y,x]=find(mtoolobj.Parent.Data.Pert.Roi.Shape.createMask);
LesPos = mtoolobj.Parent.Data.Pert.LesionPosition;
NumData = mtoolobj.Parent.Data.Pert.NumData;
Thickness = mtoolobj.Parent.Data.DatInfo.CH.ConstThick;
y = unique(y); x = flip(unique(x));
y = -(y-LesPos(1)); x = x - LesPos(2);
[X,Y]=meshgrid(x,y);
Y = Y'; X = X';
X = X(:).*mtoolobj.Parent.ScaleFactor/10;
Y = Y(:).*mtoolobj.Parent.ScaleFactor/10;
thickness = inputdlg({'Available thickness','Lesion depth'},'Enter thickness',[1 42],{num2str(Thickness),num2str(Thickness/2)});
if isempty(thickness), message = 'aborted'; return; end
shift = inputdlg('Temporal shift','Enter shift',[1 42]);
if isempty(shift), message = 'aborted'; return; end
th=array2table(horzcat(ones(NumData,1),(1:NumData)',zeros(NumData,2),repelem(str2double(shift{1}),NumData,1),zeros(NumData,3),X,Y,repelem(str2double(thickness{2}),NumData,1)));
th.Properties.VariableNames = {'Proc'	'Page'	'Offset'	'Lambda'    'ShiftInit'	'DetX'	'DetY'	'DetAlpha'	'IncPosX'	'IncPosY'	'IncPosZ'};
[FileName,FilePath,FilterIndex]=uiputfilecustom('.multi','Save table');
if FilterIndex == 0, return, end
writetable(th,fullfile(FilePath,FileName),'WriteRowNames',false,'WriteVariableNames',true,'FileType','text','Delimiter','tab');
msgbox({['Multicurve generated: ',FileName],['Data num: ',num2str(mtoolobj.Parent.Data.Pert.NumData)]},'Done','help')
message = 'Generated DAT';
end