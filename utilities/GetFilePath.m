function GetFilePath(src,~,type,MFH)
[FileName,PathName,FilterIndex]=uigetfilecustom('*.txt;*.dat;*.fit;*.trs');
if FilterIndex == 0, return, end
H = guidata(gcbo);
FullPath = fullfile(PathName,FileName);
switch type
    case 'fit'
        H.FitFilePath = FullPath;
        MFH.UserData.FitFilePath = FullPath;
        src.UserData.FitFilePath = FullPath;
        H.DispFitFilePath.String = FileName;
    case 'dat'
        H.DatFilePath = FullPath;
        MFH.UserData.DatFilePath = FullPath;
        src.UserData.DatFilePath = FullPath;
        H.DispDatFilePath.String = FileName;
    case 'irf'
        H.IrfFilePath = FullPath;
        MFH.UserData.IrfFilePath = FullPath;
        src.UserData.IrfFilePath = FullPath;
        H.DispIrfFilePath.String = FileName;
    case 'trs'
        H.TRSSetFilePath = FullPath;
        MFH.UserData.TRSSetFilePath = FullPath;
        src.UserData.TRSSetFilePath = FullPath;
        H.DispTRSSetFilePath.String = FileName;
end
guidata(gcbo,H)
end

