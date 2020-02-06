function message = GenerateMulticurve(mtoolobj)
[r,c]=find(mtoolobj.Parent.Data.Pert.Roi.Shape.createMask);
LesPos = mtoolobj.Parent.Data.Pert.LesionPosition;
NumData = mtoolobj.Parent.Data.Pert.NumData;
Thickness = mtoolobj.Parent.Data.DatInfo.CH.ConstThick;
r = unique(r); c = flip(unique(c));
r = r-LesPos(1); c = c - LesPos(2);
[X,Y]=meshgrid(r,c);
X = X(:).*mtoolobj.Parent.ScaleFactor;
Y = Y(:).*mtoolobj.Parent.ScaleFactor;
answer = inputdlg({'Available thickness','Lesion depth'},'Enter thickness',[1 42],{num2str(Thickness),num2str(Thickness/2)});
if isempty(answer), message = 'aborted'; return; end
th=array2table(horzcat(ones(NumData,1),(1:NumData)',zeros(NumData,5),X,Y,repelem(str2double(answer{2}),NumData,1)));
th.Properties.VariableNames = {'Proc'	'Page'	'Offset'	'Lambda'	'DetX'	'DetY'	'DetAlpha'	'IncPosX'	'IncPosY'	'IncPosZ'};
[FileName,FilePath,FilterIndex]=uiputfilecustom('.xlsx','Save table');
if FilterIndex == 0, return, end
writetable(th,fullfile(FilePath,FileName),'WriteRowNames',false,'WriteVariableNames',true);
message = 'Generated DAT';
end