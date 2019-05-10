function FH=CreateOrFindFig(Name,varargin)
FH = findobj('Type','figure','-and','Name',Name);
if ~isempty(FH)
    figure(FH);
else
    FH = FFS('Name',Name,varargin{:});
end