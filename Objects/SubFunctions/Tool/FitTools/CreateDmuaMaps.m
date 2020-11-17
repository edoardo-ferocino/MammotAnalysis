function [message]=CreateDmuaMaps(figobj)
[Path,FileName,Ext]=fileparts(figobj.Data.Fit.DataFilePath);
RefPathFilePath = fullfile(Path,strcat(FileName,'_REFPATH',Ext));
if ~isfile(RefPathFilePath)
    DisplayError('No REFPATH present','Be sure to have the REFPATH file');
    return
end
opts = detectImportOptions(RefPathFilePath);
opts.ExtraColumnsRule = 'ignore';
Paths = readtable(RefPathFilePath, opts);
Paths = Paths.Variables;
[NumLambda,NumGates]=size(Paths);

Logicals = any(cell2mat(figobj.Data.Fit.ActualRows),2);
nCols = max(figobj.Data.Fit.Data.X)+1;
nRows = max(figobj.Data.Fit.Data.Y)+1;
Gates = zeros(nCols,nRows,NumLambda,NumGates);
for ig = 1:NumGates
    Gate = figobj.Data.Fit.Data.(strcat('Gate_',num2str(ig-1)))(Logicals);
    Gates(:,:,:,ig) = reshape(Gate,nCols,nRows,NumLambda);
end

Dmua = zeros(nCols,nRows,NumLambda);
for il = 1:NumLambda
    for ic = 1:nCols
        for ir = 1:nRows
            gate = squeeze(Gates(ic,ir,il,:));
            if(all(gate>0))
                Dmua(ic, ir, il) = Paths(il, :)'\-log(gate);
            end
        end
    end
end
RowsToPad = not(all(squeeze(sum(Dmua,1,'omitnan'))~=0,2));
Dmua(:,RowsToPad,:) = zeros(nCols,sum(RowsToPad),NumLambda);
NewFit = figobj.Data.Fit;
NewFit.Data.Dmua(Logicals) = Dmua(:);
NewFit.Type = 'Dmua';
OldParams = not(any(vertcat(strcmpi({NewFit.Params.Name},'x'),strcmpi({NewFit.Params.Name},'y')),1));
NewFit.Params(OldParams) = [];
NewFit.Params(end+1).ColID = size(NewFit.Data,2);
NewFit.Params(end).Name = 'Dmua';
NewFit.Params(end).Type = 'double';
Page = cell.empty(NumLambda,0);
for il = 1:NumLambda
    Page{il} = NewFit.Data(NewFit.ActualRows{il},vertcat(NewFit.Params.ColID));
end
PlotPage(Page,NewFit);
message = 'Dmua maps created';
end