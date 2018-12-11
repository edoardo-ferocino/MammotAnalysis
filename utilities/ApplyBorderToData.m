function Data = ApplyBorderToData(MFH,Data)
try
    [~,~,NumChan,NumBin]=size(Data);
    if isfield(MFH.UserData,'DataMask')
        if strcmpi(MFH.UserData.DataMaskDelType,'external')
            Data = Data .*repmat(MFH.UserData.DataMask,[1 1 NumChan NumBin]);
        else
            Data = Data .*~repmat(MFH.UserData.DataMask,[1 1 NumChan NumBin]);
        end
    end
catch ME
    if strcmpi(ME.identifier,'MATLAB:dimagree')
        if isempty(findobj('Tag','Msgbox_Fail'))
            fh = gcf;
            mh = msgbox('Can''t apply the border to the specified filter set','Fail','warn');
            movegui(mh,'center');
            figure(fh);
        end
    else
        ME.rethrow;
    end
end
end