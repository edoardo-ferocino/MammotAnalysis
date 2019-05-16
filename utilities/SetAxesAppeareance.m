function SetAxesAppeareance(AxH,varargin) 
    for iax =1:numel(AxH)
    AxH(iax).YDir = 'reverse';
    axis image;cb = colorbar(varargin{:}); colormap pink, shading interp;
    AxH(iax).UserData.OriginalCLims = cb.Limits;
    end
end