function Spe = GetExtCoeff(mfigobj)
mainpanelobj =  mfigobj.GetMainPanel;
if ~isfield(mainpanelobj.Data,'SpeFilePath')
    DisplayError('No spe file','Please load the spe file');
    return
else
    SpectraFileName = mainpanelobj.Data.SpeFilePath{:};
    opts = detectImportOptions(SpectraFileName,'FileType','text');
    SpectraData=readtable(SpectraFileName,opts,'ReadVariableNames',1);%,'Delimiter','\t','EndOfLine','\r\n');
    SubsetExtCoeff=SpectraData(ismember(SpectraData.lambda_nm_,mainpanelobj.Wavelengths),2:2+4);
    AllExtCoeff=SpectraData(:,2:2+4);
    SubsetVarExtCoeff=SubsetExtCoeff.Variables;
    AllVarExtCoeff=AllExtCoeff.Variables;
    Lambda = SpectraData(:,1).Variables;
    Spe.ExtCoeff = SubsetVarExtCoeff; 
    Spe.AllExtCoeff = AllVarExtCoeff;
    Spe.Lambda = Lambda;
    Spe.Chromophores = SpectraData.Properties.VariableNames(2:end-1);
end
end