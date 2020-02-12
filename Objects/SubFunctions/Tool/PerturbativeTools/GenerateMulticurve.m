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
answer = inputdlg({'Available thickness','Lesion depth'},'Enter thickness',[1 42],{num2str(Thickness),num2str(Thickness/2)});
if isempty(answer), message = 'aborted'; return; end
th=array2table(horzcat(ones(NumData,1),(1:NumData)',zeros(NumData,6),X,Y,repelem(str2double(answer{2}),NumData,1)));
th.Properties.VariableNames = {'Proc'	'Page'	'Offset'	'Lambda'    'VarShiftInit'	'DetX'	'DetY'	'DetAlpha'	'IncPosX'	'IncPosY'	'IncPosZ'};
[FileName,FilePath,FilterIndex]=uiputfilecustom('.multi','Save table');
if FilterIndex == 0, return, end
writetable(th,fullfile(FilePath,FileName),'WriteRowNames',false,'WriteVariableNames',true,'FileType','text','Delimiter','tab');
msgbox({['Multicurve generated: ',FileName],['Data num: ',num2str(mtoolobj.Parent.Data.Pert.NumData)]},'Done','help')
message = 'Generated DAT';
end