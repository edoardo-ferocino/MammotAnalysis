function [BkgFreeData,varargout] = IrfBkgSubtract(Data,Region,varargin)
Bkg = mean(Data(:,Region),2);
BkgFreeData = Data - Bkg;
if nargin>2
    if strcmpi(varargin{1},'noneg')
        BkgFreeData(BkgFreeData<0)=0;
    end
end
if nargout>1
    varargout{1} = Bkg;
end
end