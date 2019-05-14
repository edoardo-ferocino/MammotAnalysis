function FH=CreateOrFindFig(Name,isFFS,varargin)
FH = findobj(groot,'Type','figure','-and','Name',Name,'-and',varargin{:});
if ~isempty(FH)
    figure(FH);
else
    if(isFFS)
        FH = FFS('Name',Name,varargin{:});
        FH.UserData.isFFS = true;
    else
        FH = figure('Name',Name,varargin{:});
        FH.UserData.isFFS = false;
    end
end