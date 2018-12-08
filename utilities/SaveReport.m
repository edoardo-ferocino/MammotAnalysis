function SaveReport(~,~,MFH)
Text = MFH.UserData.Report.String;
if isempty(Text), return; end
[FileName,PathName,FilterIdx] = uiputfilecustom('*.doc','Select destination folder');
if FilterIdx == 0, return; end
Text_H = ['Data File: ' MFH.UserData.DispDatFilePath.String];
Text_H = char(Text_H,['Irf File: ' MFH.UserData.DispIrfFilePath.String]);
Text_H = char(Text_H,['Fit File: ' MFH.UserData.DispFitFilePath.String]);
StartWait(MFH)
[ActXWord,WordHandle] = StartWord(fullfile(PathName,FileName),1);
WordText(ActXWord,Text_H,'Normal',[0,1]);%enter after text
WordText(ActXWord,Text,'Normal',[0,1]);%enter after text
CloseWord(ActXWord,WordHandle,fullfile(PathName,FileName))
StopWait(MFH)
end