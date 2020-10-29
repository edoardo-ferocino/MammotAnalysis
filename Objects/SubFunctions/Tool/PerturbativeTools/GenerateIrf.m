function message = GenerateIrf(mtoolobj)

mselectfigobj = mtoolobj.Parent.SelectMultipleFigures([],[],'select',['Roi for ',mtoolobj.Parent.Data.FileName]);
waitfor(mselectfigobj.Figure,'Visible','off');
if strcmpi(mselectfigobj.Data.ExitStatus,'Exit')
    message = 'aborted';
    return;
elseif strcmpi(mselectfigobj.Data.ExitStatus,'Ok')
    IrfFigObj = mselectfigobj.Data.SelectedFigure;
end
IrfFigObj.Selected = false;

if size(IrfFigObj.Data.PickData,2)~=1 || ~contains(IrfFigObj.Name,'Curves per channel','IgnoreCase',true) || isstruct(IrfFigObj.Data.PickData)
   DisplayError('Chosen IRF not suitable','Contact developer');
   return
end

NumData = mtoolobj.Parent.Data.Pert.NumData;
CH = IrfFigObj.Data.DatInfo.CH;
SUBH = IrfFigObj.Data.DatInfo.SUBH;
CH.LoopNum(1) = NumData;
H = CompileHeader(CH);
[FileName,FilePath,FilterIndex]=uiputfilecustom('.DAT','Save table');
if FilterIndex == 0, return; end
% [FilePath,FileName]=fileparts(IrfFigObj.Data.DataFilePath);
fid_out = fopen(strcat(fullfile(FilePath,FileName)), 'wb');
fwrite(fid_out, H, 'uint8');
for irep = 1:NumData
    fwrite(fid_out, SUBH, 'uint8');
    fwrite(fid_out,IrfFigObj.Data.PickData, 'uint32');
end
fclose(fid_out);
msgbox({['Irf generated: ',FileName],['Data num: ',num2str(mtoolobj.Parent.Data.Pert.NumData)]},'Done','help')
message = 'Irf generated';
end