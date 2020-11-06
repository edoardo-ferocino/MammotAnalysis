function ReadFitData(~,~,MPOBJ)
if ~isfield(MPOBJ.Data,'FitFilePath')
    DisplayError('No fit file','Please load the Fit file');
    return
end
MPOBJ.StartWait;
for infile = 1:MPOBJ.Data.FitFileNumel
    clearvars('-except','MPOBJ','infile');
    FitFileName = MPOBJ.Data.FitFilePath{infile};
    opts = detectImportOptions(FitFileName);
    VarTypes = opts.VariableTypes;
    FitData=readtable(FitFileName,opts,'ReadVariableNames',true);
    if any(strcmpi(FitData.Properties.VariableNames,'ExtraVar1'))
        FitData = FitData(:,~strcmpi(FitData.Properties.VariableNames,'ExtraVar1'));
    end
    FitData.Properties.VariableUnits = VarTypes;
    OriginalColNames = {'loop3actual','loop2actual','CodeActual','varconc00opt','varconc01opt',...
        'varconc02opt','varconc03opt','varconc04opt','vara0opt','varb0opt','varmua0opt','varmus0opt'}';
    RealColNames = {'X','Y','CodeActualLoop','Hb','HbO2','Lipid',...
        'Water','Collagen','A','B','Absorption','Scattering'}';
    ColumnNames = FitData.Properties.VariableNames;
    CompNames = {'Hb' 'HbO2' 'Lipid' 'Water' 'Collagen' 'A' 'B' 'SO2' 'HbTot'}';
    MuaMusNames = {'Absorption','Scattering'}';
    LocationNames = {'X','Y'}';
    for ic = 1:numel(ColumnNames)
        cats = unique(FitData.(ColumnNames{ic}),'stable');
        if strcmpi(FitData.Properties.VariableUnits{ic},'char')
            if ~isempty(regexpi(cats{1},'ses\w?','match'))
                FitData.Properties.VariableNames(ic) = {'Session'};
            elseif ~isempty(regexpi(cats{1},'rep\w?','match'))
                FitData.Properties.VariableNames(ic) = {'Repetition'};
            elseif ~isempty(regexpi(cats{1},'(?<!\w)DX(?!=\w)|(?<!\w)SX(?!=\w)|^R|^L','match'))
                if strcmpi(cats{1},'DX')==false&&strcmpi(cats{1},'SX')==false
                    if strcmpi(cats{1},'r')||strcmpi(cats{1},'l')
                        FitData.Properties.VariableNames(ic) = {'Breast'};
                    end
                else
                    FitData.Properties.VariableNames(ic) = {'Breast'};
                end
            elseif ~isempty(regexpi(cats{1},'(?<!\w)CC(?!=\w)|(?<!\w)OB(?!=\w)','match'))
                FitData.Properties.VariableNames(ic) = {'View'};
            elseif ~isempty(regexpi(cats{1},'(Patient)\w?','match'))
                FitData.Properties.VariableNames(ic) = {'Patient'};
            end
        elseif strcmpi(FitData.Properties.VariableUnits{ic},'double')
            if ismember(cats,MPOBJ.Wavelengths)
              FitData.Properties.VariableNames(ic) = {'Lambda'};
            end
        end
        match = find(strcmpi(OriginalColNames,ColumnNames{ic}));
        if match
            FitData.Properties.VariableNames{ic} = RealColNames{match};
        end
    end
    if any(strcmpi(FitData.Properties.VariableNames,MuaMusNames{1}))
        Type = 'OptProps';
        FitParamsNames = MuaMusNames;
    elseif any(strcmpi(FitData.Properties.VariableNames,CompNames{1}))
        Type = 'Spectral';
        FitData.HbTot = FitData.Hb+FitData.HbO2;
        FitData.SO2 = FitData.HbO2./FitData.HbTot .* 100;
        FitData.SO2(isnan(FitData.SO2))=0;
        FitData.Properties.VariableUnits(end-1:end)={'double','double'};
        FitData = movevars(FitData,{'HbTot' 'SO2'},'After','Collagen');
        FitParamsNames = CompNames;
    end
    ColumnNames = FitData.Properties.VariableNames;
    ifil = 1; ifitp = 1; Vect2Match = vertcat(FitParamsNames,LocationNames);
    for ic = 1:numel(ColumnNames)
        match = find(strcmpi(Vect2Match,ColumnNames{ic}));
        if match
            Params(ifitp,1).Name = Vect2Match{match}; %#ok<*AGROW>
            Params(ifitp,1).ColID = ic;
            Params(ifitp,1).Type = VarTypes{ic};
            ifitp = ifitp +1;
        else
            Filters(ifil,1).Categories = unique(FitData.(ColumnNames{ic}),'sorted');
            if numel(Filters(ifil,1).Categories)>50&&~strcmpi(ColumnNames{ic},'codeactualloop')
                continue;
            end
            if strcmpi(FitData.Properties.VariableUnits{ic},'double')
              Filters(ifil,1).Categories=num2cell(Filters(ifil,1).Categories); 
            end
            Filters(ifil,1).Categories = horzcat('Any',Filters(ifil,1).Categories');
            Filters(ifil,1).SelectedCategory = 'Any';
            Filters(ifil,1).Name = ColumnNames{ic};
            Filters(ifil,1).LambdaFilter = false;
            if strcmpi(Filters(ifil,1).Name,'Lambda')
                Filters(ifil,1).LambdaFilter = true;
            end
            Filters(ifil,1).ColID = ic;
            Filters(ifil,1).Type = FitData.Properties.VariableUnits{ic};
            ifil = ifil +1;
        end
    end
    XColID = find(strcmpi(ColumnNames,'X'));
    FitData(:,XColID).Variables = flip(FitData(:,XColID).Variables);
    Fit.Params = Params;Fit.Type = Type;Fit.Filters = Filters;Fit.Data = FitData;
    Fit.DataFilePath = MPOBJ.Data.FitFilePath{infile};
    SetFitFilters(Fit,MPOBJ.Data.FitFilePath{infile},MPOBJ.Graphical.AutoRunFit.Value);
end
MPOBJ.SelectMultipleFigures([],[],'show');
MPOBJ.StopWait;
end


