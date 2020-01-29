function message = PickSpectraOnImage(mtoolobj)
dch = datacursormode(mtoolobj.Parent.Figure);
datacursormode on
dch.DisplayStyle = 'window';
dch.UpdateFcn = {@PickSpectra,mtoolobj.Parent};
message = 'Pick Spectra applied';
end
function output_txt=PickSpectra(datacursorobj,~,mfigobj)
persistent PreviousParent
persistent Times
pos = datacursorobj.Position; cpos = pos(1); rpos = pos(2);
AxesNames = {mfigobj.Axes.Name};
maxesobj = mfigobj.Axes(strcmpi(AxesNames,datacursorobj.Parent.Title.String));
if isempty(PreviousParent)||isequal(PreviousParent,maxesobj)
    PreviousParent = maxesobj;
    Times = 1;
else
    if ~isequal(PreviousParent,maxesobj)
        if Times == 1
            Times = Times + 1;
            output_txt = {'Wait'};
            return;
        else
            Times = 1;
            PreviousParent = maxesobj;
        end
    end
end
MP = get(0, 'MonitorPositions');
if size(MP, 1) == 1  % Single monitor
    maxesobj.Parent.Figure.WindowState = 'normal';
end
mfigobj=mfigure('Name',['Pick spectra. ',maxesobj.Parent.Name],'Category','Pick Spectra');
isspectral = regexpi(maxesobj.Name,'^a|^b|^collagen|^lipid|^water|^hb|^hbo2|^hbtot|^so2');%\lambda\s=*\s(\d)+','tokens');
isoptprops = regexp(maxesobj.Name,'\\mu_{a}|\\mu_{s}''', 'once');%Channel ([0-9]?)','tokens');
if ~isempty(isspectral)
    AbsCompNames = {'Hb' 'HbO2' 'Lipid' 'Water' 'Collagen'}';
    CompValues = zeros(size(AbsCompNames));
    ScaCompNames = {'A' 'B'}';
    ScaValues = zeros(size(ScaCompNames));
    if ~isfield(maxesobj.Parent.Data,'Spe')
        maxesobj.Parent.Data.Spe=GetExtCoeff(maxesobj.Parent);
    end
    IndipAbsorptionSpectra = zeros(size(maxesobj.Parent.Data.Spe.AllExtCoeff));
    AxesNames = {maxesobj.Parent.Axes.Name};
    for ia = 1:numel(AbsCompNames)
        CompValues(ia)=maxesobj.Parent.Axes(strcmpi(AxesNames,AbsCompNames(ia))).ImageData(rpos,cpos);
        IndipAbsorptionSpectra(:,ia) = maxesobj.Parent.Data.Spe.AllExtCoeff(:,ia).*CompValues(ia);
    end
    AbsorptionSpectra = sum(IndipAbsorptionSpectra,2);
    for ia = 1:numel(ScaCompNames)
        ScaValues(ia)=maxesobj.Parent.Axes(strcmpi(AxesNames,ScaCompNames(ia))).ImageData(rpos,cpos);
    end
    ScatteringSpectra = ScaValues(1).*(maxesobj.Parent.Data.Spe.Lambda/maxesobj.Parent.Wavelengths(1)).^(-ScaValues(2));
    Lambda = maxesobj.Parent.Data.Spe.Lambda;
elseif ~isempty(isoptprops)
    AbsorptionSpectra = zeros(size(mfigobj.Wavelengths));
    ScatteringSpectra = zeros(size(mfigobj.Wavelengths));
    for ia = 1:maxesobj.Parent.nAxes
        mua_lambda = regexp(maxesobj.Parent.Axes(ia).Name,'\\mu_{a}, \\lambda = (\d*)', 'tokens');
        if ~isempty(mua_lambda)
            mua_lambda=mua_lambda{1};mua_lambda=mua_lambda{1};mua_lambda=str2double(mua_lambda);
            AbsorptionSpectra(ismember(mfigobj.Wavelengths,mua_lambda))=maxesobj.Parent.Axes(ia).ImageData(rpos,cpos);
        end
        mus_lambda = regexp(maxesobj.Parent.Axes(ia).Name,'\\mu_{s}'', \\lambda = (\d*)', 'tokens');
        if ~isempty(mus_lambda)
            mus_lambda=mus_lambda{1};mus_lambda=mus_lambda{1};mus_lambda=str2double(mus_lambda);
            ScatteringSpectra(ismember(mfigobj.Wavelengths,mus_lambda))=maxesobj.Parent.Axes(ia).ImageData(rpos,cpos);
        end
    end
    fitlambda = linspace(mfigobj.Wavelengths(1),mfigobj.Wavelengths(end),500);
    AbsorptionSpectra = interp1(mfigobj.Wavelengths,AbsorptionSpectra,fitlambda,'pchip')';
    ScatteringSpectra = interp1(mfigobj.Wavelengths,ScatteringSpectra,fitlambda)';
    Lambda = fitlambda;IndipAbsorptionSpectra = [];
end
subplot1(2,1,'min',[0.12 0.15],'max',[0.98 0.98]);
subplot1(1);
plot(Lambda,AbsorptionSpectra,'LineWidth',2);
if ~isempty(isspectral)
    hold on
    plot(Lambda,IndipAbsorptionSpectra);
    % legend(gca,vertcat('All',AbsCompNames));
    [~,loc]=ismember(mfigobj.Wavelengths,Lambda);
else
    [~,closestIndex] = arrayfun(@(iw) min(abs(bsxfun(@minus,iw, Lambda))),mfigobj.Wavelengths);
    loc = closestIndex;
end
plot(mfigobj.Wavelengths,AbsorptionSpectra(loc),'LineStyle','none','Marker','o');
text(mfigobj.Wavelengths,AbsorptionSpectra(loc)+0.1,num2str(AbsorptionSpectra(loc),'%.2f'));
xlabel({'Wavelenghts [nm]'})
ylabel({'\mu_{a} [cm^{-1}]'})
ylim([0 0.6])
subplot1(2);
plot(Lambda,ScatteringSpectra,'LineWidth',2);
hold on
plot(mfigobj.Wavelengths,ScatteringSpectra(loc),'LineStyle','none','Marker','o');
text(mfigobj.Wavelengths,ScatteringSpectra(loc)+1,num2str(ScatteringSpectra(loc),'%.2f'));
xlabel({'Wavelenghts [nm]'})
ylabel({'\mu_{s}'' [cm^{-1}]'})
ylim([0 15])
if ~isempty(isspectral)
    FormattedString = strcat([AbsCompNames;ScaCompNames], repmat({': '},numel(AbsCompNames)+2,1),(num2str([CompValues;ScaValues],'%.1f')));
else
    %FormattedString = strcat(['\mu_{a}';'\mu_{s}'''], repmat({': '},numel(mfigobj.Wavelengths),1),(num2str([mua;mua],'%.1f')));
    FormattedString = {strcat('Z: ',num2str(maxesobj.ImageData(rpos,cpos)))};
end
maxesobj.Parent.Show;
output_txt = vertcat(...
    {strcat('X: ',num2str(round(cpos)))},...
    {strcat('Y: ',num2str(round(rpos)))},...
    FormattedString);
end