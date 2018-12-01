function ReadFitData(src,event,FitFileName)
H = guidata(gcbo);
StartWait(H.MFH)
FitFileName = H.FitFilePath;
AllData=readtable(FitFileName,'ReadVariableNames',1,'Delimiter','\t','EndOfLine','\r\n');
H.FitAllData = AllData;
% Cats.LambdaCats = categories(categorical(AllData.Lambda));
% Wavelenghts=cellfun(@str2num,Cats.LambdaCats);
% Cats.Yindx = categories(categorical(AllData.Loop2Actual));
% Yindx=cellfun(@str2num,Cats.Yindx);
% Cats.Xindx = categories(categorical(AllData.Loop3Actual));
% Xindx=cellfun(@str2num,Cats.Xindx);
ColumnNames = AllData.Properties.VariableNames;
Indx.X=find(strcmpi(ColumnNames,'loop3actual'));
AllData.Properties.VariableNames{Indx.X}='X';
Indx.Y=find(strcmpi(ColumnNames,'loop2actual'));
AllData.Properties.VariableNames{Indx.Y}='Y';
nConc = sum(contains(lower(AllData.Properties.VariableNames),'varconc'))+2;
nScaP = 2;
[nsub]=numSubplots(nConc);
CompNames = {'Hb' 'HbO2' 'H20' 'Lipid' 'Collagen' 'HbTot' 'So2' 'A' 'B'};
if isfield(H,'FH')
    H.FH(end+1)=FFS('Name','Components');
else
    H.FH = FFS('Name','Components');
end
subH=subplot1(nsub(1),nsub(2));
for ic = 1:nConc-2
    indx=find(strcmpi(ColumnNames,['varconc0' num2str(ic-1) 'opt']));
    Indx.(CompNames{ic})=indx;
    AllData.Properties.VariableNames{indx}=CompNames{ic};
    C.(CompNames{ic}) = AllData(:,[Indx.(CompNames{ic}) Indx.X Indx.Y]);
    C.(CompNames{ic})=...
        unstack(C.(CompNames{ic}),CompNames{ic},'X','AggregationFunction',@mean);
    C.(CompNames{ic})(:,1)=[];
    subplot1(ic);
    imagesc(C.(CompNames{ic}).Variables);
    colormap pink, shading interp, axis image;
    title(CompNames{ic})
    colorbar('southoutside')
    H.C.(CompNames{ic}) = C.(CompNames{ic});
end
C.HbTot.Variables = C.Hb.Variables+C.HbO2.Variables;
subplot1(ic+1);
imagesc(C.HbTot.Variables);
colormap pink, shading interp, axis image;
title(CompNames{ic+1})
colorbar('southoutside')
C.So2.Variables = C.HbO2.Variables./C.HbTot.Variables;
subplot1(ic+2);
imagesc(C.So2.Variables);
colormap pink, shading interp, axis image;
title(CompNames{ic+2})
colorbar('southoutside')
delete(subH(nConc+1:end));
H.C.HbTot = C.HbTot;
H.C.So2 = C.So2;
H.C.SubH = subH;

numAddedFigs = 1;
for ifigs = numel(H.FH)-(numAddedFigs-1):numel(H.FH)
   H.FH(ifigs).Visible = 'off';
   H.FH(ifigs).CloseRequestFcn = {@SetFigureInvisible,H.FH(ifigs)};
   AddElementToList(H.ListFigures,H.FH(ifigs));
end
StopWait(H.MFH)
guidata(gcbo,H);
end


