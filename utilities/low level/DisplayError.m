function DisplayError(message,action)
errordlg({message action},'Error','modal');
assignin('caller','message',message);
end