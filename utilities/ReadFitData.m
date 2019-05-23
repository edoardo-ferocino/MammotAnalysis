function ReadFitData(~,~,MFH)
if ~isfield(MFH.UserData,'FitFilePath')
    errordlg('Please load the Fit file','Error');
    return
end
StartWait(MFH)
for infile = 1:MFH.UserData.FitFileNumel
    clearvars('-except','MFH','infile');
    FitFileName = MFH.UserData.FitFilePath{infile};
    opts = detectImportOptions(FitFileName);
    VarTypes = opts.VariableTypes;
    FitData=readtable(FitFileName,opts,'ReadVariableNames',1);%,'Delimiter','\t','EndOfLine','\r\n');
    
    OriginalColNames = {'loop3actual','loop2actual','CodeActual','varconc00opt','varconc01opt',...
        'varconc02opt','varconc03opt','varconc04opt','vara0opt','varb0opt','varmua0opt','varmus0opt'};
    RealColNames = {'X','Y','CodeActualLoop','Hb','HbO2','Lipid',...
        'H20','Collagen','A','B','mua','mus'};
    ColumnNames = FitData.Properties.VariableNames;
    CompNames = {'Hb' 'HbO2' 'Lipid' 'H20' 'Collagen' 'A' 'B'};
    MuaMusNames = {'mua','mus'};
    LocationNames = {'X','Y'};
    Labels = {'Repetition' 'View' 'Breast' 'Session'};
    Content = [ ["rep" "repetition" "-" "-"];...
        ["OB" "CC" "CL" "-"];...
        ["SX" "DX" "L" "R"];...
        ["ses" "session" "-" "-"]];
    for ic = 1:numel(ColumnNames)
        match = find(strcmpi(OriginalColNames,ColumnNames{ic}));
        try
            Cats = categories(categorical(FitData.(ColumnNames{ic})))';
            if isempty(Cats), continue, end
            if strcmpi(VarTypes{ic},'char')
                for ilabs = 1:numel(Labels)
                    for icats = 1:numel(Cats)
                        TempCatChar = Cats{icats};
                        TempCat = TempCatChar(isletter(TempCatChar));
                        if any(strcmpi(TempCat,Content(ilabs,:)))
                            FitData.Properties.VariableNames(ic) = Labels(ilabs);
                            continue
                        end
                    end
                end
            end
        catch ME
            if ~strcmpi(ME.identifier,'MATLAB:categorical:CantCreateCategoryNames')
                throw(ME);
            end
        end
        if match
            FitData.Properties.VariableNames{ic} = RealColNames{match};
        end
    end
    ColumnNames = FitData.Properties.VariableNames;
    
    if any(strcmpi(ColumnNames,MuaMusNames{1}))
        fitType = 'muamus';
        FitParamsNames = MuaMusNames;
    end
    if any(strcmpi(ColumnNames,CompNames{1}))
        fitType = 'conc';
        FitParamsNames = CompNames;
    end
    ifil = 1; ifitp = 1; Vect2Match = [FitParamsNames,LocationNames];
    for ic = 1:numel(ColumnNames)
        match = find(strcmpi(Vect2Match,ColumnNames{ic}));
        if match
            FitParams(ifitp).Name = Vect2Match{match}; %#ok<*AGROW>
            FitParams(ifitp).ColID = ic;
            FitParams(ifitp).Type = VarTypes{ic};
            FitParams(ifitp).FitType = fitType;
            ifitp = ifitp +1;
        else
            try
                Filters(ifil).Categories = categories(categorical(FitData.(ColumnNames{ic})));
                if ~isempty(Filters(ifil).Categories)
                    if numel(Filters(ifil).Categories)>100&&~strcmpi(ColumnNames{ic},'codeactualloop')
                        continue;
                    end
                    if isequal(str2double(Filters(ifil).Categories'),MFH.UserData.Wavelengths)
                        ColumnNames{ic} = 'Wavelenghts';
                        FitData.Properties.VariableNames(ic) = ColumnNames(ic);
                    end
                    Filters(ifil).Categories = ['Any' Filters(ifil).Categories'];
                    Filters(ifil).Name = ColumnNames{ic};
                    Filters(ifil).ColID = ic;
                    Filters(ifil).Type = VarTypes{ic};
                    Filters(ifil).FitType = fitType;
                    ifil = ifil +1;
                else
                    Filters(ifil) = [];
                end
            catch ME
                if ~strcmpi(ME.identifier,'MATLAB:categorical:CantCreateCategoryNames')
                    throw(ME);
                end
            end
        end
    end
    XColID = find(strcmpi(ColumnNames,'X'));
    FitData(:,XColID).Variables = flip(FitData(:,XColID).Variables);
    StopWait(MFH)
    SetFiltersForFit(FitData,FitParams,Filters,MFH,MFH.UserData.FitFilePath{infile});
end
end


