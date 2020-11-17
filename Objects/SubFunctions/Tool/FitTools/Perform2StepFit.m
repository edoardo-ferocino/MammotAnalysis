function [message,Conc,ScattParams] = Perform2StepFit(max_abs,max_sca,Spe,FitType)
OrigSize = size(max_abs(1).ImageData);
nWave = numel(max_abs);

% Absorption fit
Data = reshape([max_abs.ImageData],prod(OrigSize),nWave)';
nConc = size(Spe.ExtCoeff,2);
FitOpts = optimoptions('lsqlin','Display','off');
UpBounds = [500,500,1000,1000,500];LowBounds = - UpBounds*10;
InitCond = zeros(size(Spe.ExtCoeff,2),1);

switch FitType
    case 'lsqnonneg'
        Conc=arrayfun(@(ic)lsqnonneg(Spe.ExtCoeff,Data(:,ic)),1:prod(OrigSize),'UniformOutput',false);
        Conc = cell2mat(Conc);
    case 'lsqlin'
        Conc=arrayfun(@(ic)lsqlin(Spe.ExtCoeff,Data(:,ic),[],[],[],[],LowBounds,UpBounds,InitCond,FitOpts),1:prod(OrigSize),'UniformOutput',false);
        Conc = cell2mat(Conc);
    case 'backslash'
        Conc = Spe.ExtCoeff\Data;
        Conc = reshape(Conc,[nConc OrigSize]);
end
Conc = reshape(Conc,nConc,OrigSize(1),OrigSize(2));

% Scattering fit
ScattParams = [];
if ~isempty(max_sca)
    Data = reshape([max_sca.ImageData],prod(OrigSize),nWave)';
    InitialGuess = [20 1];
    options = optimoptions('lsqcurvefit','Display','none');
    ScattParams = zeros(2,prod(OrigSize));
    figh=uifigure('visible','off');figh.CloseRequestFcn = [];
    movegui(figh); figh.Position(3:4)= [400 100];
    figh.Visible = 'on';
    progh=uiprogressdlg(figh,'Message','Fitting the scattering parameters','Title','Fitting','Indeterminate','on');
    for ic = 1:size(Data,2)
        if sum(Data(:,ic))==0
            continue
        end
        FittParams=lsqcurvefit(@MieLaw,InitialGuess,Spe.Wavelengths',Data(:,ic),[0 0],[100 10],options);
        ScattParams(:,ic) = FittParams';
    end
    close(progh), figh.CloseRequestFcn = 'closereq';delete(figh)
    ScattParams=reshape(ScattParams,[2 OrigSize(1) OrigSize(2)]);
end
message = '2 step fitted performed';
end
function Scatt=MieLaw(x,xdata)
Scatt = x(1).*(xdata./xdata(1)).^(-x(2)); Scatt = Scatt';
end
