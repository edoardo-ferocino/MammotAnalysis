function FH=CreateOrFindFig(Name,isFFS,varargin)
FH = findobj('Type','figure','-and','Name',Name,'-and',varargin{:});
if ~isempty(FH)
    figure(FH);
else
    if(isFFS)
        FH = FFS('Name',Name,varargin{:});
    else
        FH = figure('Name',Name,varargin{:});
    end
end