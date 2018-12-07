function ReadFitData(~,~,MFH)
StartWait(MFH)
FitFileName = MFH.UserData.FitFilePath;
opts = detectImportOptions(FitFileName);
VarTypes = opts.VariableTypes;
AllData=readtable(FitFileName,opts,'ReadVariableNames',1);%,'Delimiter','\t','EndOfLine','\r\n');

OriginalColNames = {'loop3actual','loop2actual','CodeActual','varconc00opt','varconc01opt',...
    'varconc02opt','varconc03opt','varconc04opt','vara0opt','varb0opt','varmua0opt','varmus0opt'};
RealColNames = {'X','Y','CodeActualLoop','Hb','HbO2','Lipid',...
    'H20','Collagen','A','B','mua','mus'};
ColumnNames = AllData.Properties.VariableNames;
% CompNames = {'Hb' 'HbO2' 'Lipid' 'H20' 'Collagen' 'HbTot' 'So2' 'A' 'B'};
CompNames = {'Hb' 'HbO2' 'Lipid' 'H20' 'Collagen' 'A' 'B'};
MuaMusNames = {'mua','mus'};
LocationNames = {'X','Y'};

for ic = 1:numel(ColumnNames)
    match = find(strcmpi(OriginalColNames,ColumnNames{ic}));
    if match
        AllData.Properties.VariableNames{ic} = RealColNames{match};
    end
end
ColumnNames = AllData.Properties.VariableNames;

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
            Filters(ifil).Categories = categories(categorical(AllData.(ColumnNames{ic})));
            if ~isempty(Filters(ifil).Categories)
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
AllData(:,XColID).Variables = flip(AllData(:,XColID).Variables);
StopWait(MFH)
SetFiltersForFit(AllData,FitParams,Filters,MFH);
end


