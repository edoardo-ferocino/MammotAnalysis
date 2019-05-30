function SetAxesAppeareance(AxH,varargin) 
    for iax =1:numel(AxH)
    AxH(iax).YDir = 'reverse';
    axis image;cb = colorbar(varargin{:}); colormap pink, shading interp;
    ImH=findobj(AxH(iax),'type','image');
    ImH.UserData.OriginalCLims = cb.Limits;
    ImH.UserData.OriginalCData = ImH.CData;
    AxH(iax).UserData.OriginalCLims = cb.Limits;
    AxH(iax).UserData.OriginalCData = ImH.CData;
    end
end