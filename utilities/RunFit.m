function RunFit(~,~,FiltersPopUp,Fit,mfigobj)
mfigobj.StartWait;
for ifilter = 1:numel(FiltersPopUp)
    Fit.Filters(ifilter).SelectedCategory = FiltersPopUp(ifilter).String{FiltersPopUp(ifilter).Value};
    if ~strcmpi(Fit.Filters(ifilter).SelectedCategory,'Any')
        if strcmpi(Fit.Filters(ifilter).Type,'double')
            Fit.Filters(ifilter).SelectedCategory = str2double(Fit.Filters(ifilter).SelectedCategory);
        end
    end
end
[Page,Fit] = CreateActualPage(Fit);
PlotPage(Page,Fit);
mfigobj.StopWait;
end
function [Page,Fit] = CreateActualPage(Fit)
cols = vertcat(Fit.Params.ColID);
npages = 1;
if strcmpi(Fit.Type,'OptProps')
    lambdafilter = find(vertcat(Fit.Filters.LambdaFilter));
    if strcmpi(Fit.Filters(lambdafilter).SelectedCategory,'Any')
        npages = numel(Fit.Filters(lambdafilter).Categories)-1;
    end
end
Page = cell.empty(npages,0);
for ipage = 1:npages
    if npages >1
        Fit.Filters(lambdafilter).SelectedCategory=Fit.Filters(lambdafilter).Categories{ipage+1};
    end
    rows = true(size(Fit.Data(:,1).Variables,1),numel(Fit.Filters));
    for ifilter = 1:numel(Fit.Filters)
        if ~strcmpi(Fit.Filters(ifilter).SelectedCategory,'Any')&&ifilter==lambdafilter
            if strcmpi(Fit.Filters(ifilter).Type,'char')
                rows(:,ifilter) = strcmpi(Fit.Data.(Fit.Filters(ifilter).Name),Fit.Filters(ifilter).SelectedCategory);
            else
                rows(:,ifilter)= Fit.Data.(Fit.Filters(ifilter).Name) == Fit.Filters(ifilter).SelectedCategory;
            end
        end
    end
    rows = all(rows,2);
    Page{ipage} = Fit.Data(rows,cols);
end
if npages >1
    Fit.Filters(lambdafilter).SelectedCategory=vertcat(Fit.Filters(lambdafilter).Categories{2:end});
end
end
