function GetFilePath(src,event,type)
[FileName,PathName,FilterIndex]=uigetfilecustom('*.txt;*.dat;*.fit;*.trs');
if FilterIndex == 0, return, end
H = guidata(gcbo);
FullPath = fullfile(PathName,FileName);
switch type
    case 'fit'
        H.FitFilePath = FullPath;
        H.DispFitFilePath.String = FileName;
    case 'dat'
        H.DatFilePath = FullPath;
        H.DispDatFilePath.String = FileName;
    case 'irf'
        H.IrfFilePath = FullPath;
        H.DispIrfFilePath.String = FileName;
    case 'trs'
        H.TRSSetFilePath = FullPath;
        H.DispTRSSetFilePath.String = FileName;
end
guidata(gcbo,H)
end

