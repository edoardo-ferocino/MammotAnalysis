function SetAxesAppeareance(AxH,varargin) 
    for iax =1:numel(AxH)
    AxH(iax).YDir = 'reverse';
    colormap pink, shading interp, axis image; colorbar(varargin{:})
    end
end