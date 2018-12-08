function GetFilePath(src,~,type,MFH)
[FileName,PathName,FilterIndex]=uigetfilecustom('*.txt;*.dat;*.fit;*.trs');
if FilterIndex == 0, return, end
FullPath = fullfile(PathName,FileName);
switch type
    case 'fit'
        MFH.UserData.FitFilePath = FullPath;
        src.UserData.FitFilePath = FullPath;
        MFH.UserData.DispFitFilePath.String = FileName;
    case 'dat'
        MFH.UserData.DatFilePath = FullPath;
        src.UserData.DatFilePath = FullPath;
        MFH.UserData.DispDatFilePath.String = FileName;
    case 'irf'
        MFH.UserData.IrfFilePath = FullPath;
        src.UserData.IrfFilePath = FullPath;
        MFH.UserData.DispIrfFilePath.String = FileName;
    case 'trs'
        MFH.UserData.TRSSetFilePath = FullPath;
        src.UserData.TRSSetFilePath = FullPath;
        MFH.UserData.DispTRSSetFilePath.String = FileName;
end
end

