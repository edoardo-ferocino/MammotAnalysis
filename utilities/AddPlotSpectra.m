function AddPlotSpectra(parentfigure,object2attach,MFH)
[~,FileName]=fileparts(parentfigure.UserData.FitFilePath);
PickSpectraFigureName = ['PickSpectra - ' FileName];
if isempty(object2attach.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    object2attach.UIContextMenu = cmh;
else
    cmh = object2attach.UIContextMenu;
end
uimenu(cmh,'Text','Plot spectra','Callback',{@PickSpectra,parentfigure});
    function PickSpectra(src,~,figh)
        if strcmpi(src.Checked,'off')
            src.Checked = 'on';
            src.UserData.originalprops = datacursormode(figh);
        else
            src.Checked = 'off';
        end
        dch = datacursormode(figh);
        dch.removeAllDataCursors;
        if strcmpi(src.Checked,'off')
            dch.DisplayStyle = 'datatip';
            dch.UpdateFcn = [];
            return
        end
        
        datacursormode on
        dch.DisplayStyle = 'window'; ObjMenu = src;
        dch.UpdateFcn = {@PickSpectraOnGraph,ObjMenu};
    end
    function output_txt=PickSpectraOnGraph(src,~,~)
        StartWait(parentfigure);
        AncestorFigure = ancestor(src,'figure');
        pos = src.Position; Xpos = pos(1); Ypos = pos(2);
        FH=CreateOrFindFig(PickSpectraFigureName,'NumberTitle','off');
        FH.UserData.FigCategory = 'PickSpectra';
        movegui(FH,'southwest')
        if strcmpi(parentfigure.UserData.FigCategory,'MuaMus')
            ismusfig = contains(parentfigure.Name,'GlobalView: mus');
            ismuafig = contains(parentfigure.Name,'GlobalView: mua');
            if ismuafig
                otherfigname  = replace(parentfigure.Name,': mua',': mus');
                optparam = 'mua';
                othreoptparam = 'mus';
            end
            if ismusfig
                otherfigname  = replace(parentfigure.Name,': mus',': mua');
                optparam = 'mus';
                othreoptparam = 'mua';
            end
            OtherFigH=findobj(groot,'type','figure','name',otherfigname);
            AxH=findobj(parentfigure,'type','axes');
            OtherAxH=findobj(OtherFigH,'type','axes');
            for iaxh = 1:numel(AxH)
                Data(:,:,AxH(iaxh).UserData.WaveID) = AxH(iaxh).UserData.([optparam num2str(MFH.UserData.Wavelengths(AxH(iaxh).UserData.WaveID))]);
                OtherData(:,:,OtherAxH(iaxh).UserData.WaveID) = OtherAxH(iaxh).UserData.([othreoptparam num2str(MFH.UserData.Wavelengths(AxH(iaxh).UserData.WaveID))]);
                DataString{AxH(iaxh).UserData.WaveID} = AxH(iaxh).Title.String;
                OtherDataString{AxH(iaxh).UserData.WaveID} = OtherAxH(iaxh).Title.String;
            end
            samplingRateIncrease = 10;
            newXSamplePoints = linspace(min(MFH.UserData.Wavelengths), max(MFH.UserData.Wavelengths), numel(MFH.UserData.Wavelengths) * samplingRateIncrease);
            DataSmoothed = spline(MFH.UserData.Wavelengths, Data(Ypos,Xpos,:), newXSamplePoints);
            OtherDataSmoothed = spline(MFH.UserData.Wavelengths, OtherData(Ypos,Xpos,:), newXSamplePoints);
            subplot1(2,1,'min',[0.12 0.15],'max',[0.98 0.98]);
            subplot1(1);
            plot(newXSamplePoints,DataSmoothed);
            hold on
            plot(MFH.UserData.Wavelengths,squeeze(Data(Ypos,Xpos,:)),'LineStyle','none','Marker','o');
            xlabel({'Wavelenghts' '[nm]'})
            ylabel({optparam '[cm^-1]'})
            if strcmpi(optparam,'mus')
                ylim([0 15])
            else
                ylim([0 0.6])
            end
            subplot1(2);
            plot(newXSamplePoints,OtherDataSmoothed,'LineStyle','-','Marker','none');
            hold on
            plot(MFH.UserData.Wavelengths,squeeze(OtherData(Ypos,Xpos,:)),'LineStyle','none','Marker','o');
            xlabel({'Wavelenghts' '[nm]'})
            ylabel({othreoptparam '[cm^-1]'})
            if strcmpi(othreoptparam,'mus')
                ylim([0 15])
            else
                ylim([0 0.6])
            end
            DataString = [DataString', repmat({': '},numel(MFH.UserData.Wavelengths),1),num2cell(num2str([squeeze(Data(Ypos,Xpos,:))]))];
            DataString = DataString';
            OtherDataString = [OtherDataString', repmat({': '},numel(MFH.UserData.Wavelengths),1),num2cell(num2str([squeeze(OtherData(Ypos,Xpos,:))]))];
            OtherDataString = OtherDataString';
            for iw=1:numel(MFH.UserData.Wavelengths)
                DataFormattedString{iw}=[DataString{:,iw}];
                OtherDataFormattedString{iw}=[OtherDataString{:,iw}];
            end
            output_txt = [
                {strcat('X: ',num2str(round(Xpos)))},...
                {strcat('Y: ',num2str(round(Ypos)))},...
                DataFormattedString];
            AddToFigureListStruct(FH,MFH,'side')
            StopWait(parentfigure);
            figure(AncestorFigure);
            MinimizeFFS(AncestorFigure);
        end
        if strcmpi(parentfigure.UserData.FigCategory,'Spectral')||strcmpi(parentfigure.UserData.FigCategory,'2-step fit')
            if ~isfield(MFH.UserData,'SpectraFilePath')
                errordlg('Please load the spectra file','Error');
                return
            else
                SpectraFileName = MFH.UserData.SpectraFilePath{:};
                opts = detectImportOptions(SpectraFileName,'FileType','text');
                SpectraData=readtable(SpectraFileName,opts,'ReadVariableNames',1);%,'Delimiter','\t','EndOfLine','\r\n');
                SubsetExtCoeff=SpectraData(ismember(SpectraData.lambda_nm_,MFH.UserData.Wavelengths),2:2+4);
                AllExtCoeff=SpectraData(:,2:2+4);
                SubsetVarExtCoeff=SubsetExtCoeff.Variables;
                AllVarExtCoeff=AllExtCoeff.Variables;
                Lambda = SpectraData(:,1); VarLambda = Lambda.Variables;
            end
            ConcNames = {'Hb' 'HbO2' 'Lipid' 'H20' 'Collagen'};
            ScatNames = {'A' 'B'};
            AxH=findobj(parentfigure,'type','axes');
            AxTH=[AxH.Title]; AxesTitle = {AxTH.String};
            for iaxh = 1:numel(AxH)
                if any(ismember(ConcNames,AxesTitle(iaxh)))
                    DataConc(:,:,ismember(ConcNames,AxesTitle(iaxh)))=AxH(iaxh).UserData.(AxesTitle{iaxh});
                end
                if any(ismember(ScatNames,AxesTitle(iaxh)))
                    ScatParams(:,:,ismember(ScatNames,AxesTitle(iaxh)))=AxH(iaxh).UserData.(AxesTitle{iaxh});
                end
            end
            AllMua = AllVarExtCoeff*squeeze(DataConc(Ypos,Xpos,:));
            IndipSpectra = AllVarExtCoeff.*squeeze(DataConc(Ypos,Xpos,:))';
            SubsetMua = SubsetVarExtCoeff*squeeze(DataConc(Ypos,Xpos,:));
            AllMus = ScatParams(Ypos,Xpos,1).*(VarLambda./MFH.UserData.Wavelengths(1)).^(-ScatParams(Ypos,Xpos,2));
            SubsetMus = ScatParams(Ypos,Xpos,1).*(MFH.UserData.Wavelengths'./MFH.UserData.Wavelengths(1)).^(-ScatParams(Ypos,Xpos,2));
%             samplingRateIncrease = 10;
%             newXSamplePoints = linspace(min(MFH.UserData.Wavelengths), max(MFH.UserData.Wavelengths), numel(MFH.UserData.Wavelengths) * samplingRateIncrease);
%             MuaSmoothed = spline(MFH.UserData.Wavelengths, Mua, newXSamplePoints);
%             MusSmoothed = spline(MFH.UserData.Wavelengths, Mus, newXSamplePoints);
            subplot1(2,1,'min',[0.12 0.15],'max',[0.98 0.98]);
            subplot1(1);
            plot(VarLambda,AllMua,'LineWidth',2);
            hold on
            IndipSpectraObj=plot(VarLambda,IndipSpectra); 
            plot(MFH.UserData.Wavelengths,SubsetMua,'LineStyle','none','Marker','o');
            legend(IndipSpectraObj,ConcNames);
            text(MFH.UserData.Wavelengths,SubsetMua+0.1,num2str(SubsetMua,'%.2f'));
            xlabel({'Wavelenghts' '[nm]'})
            ylabel({'mua' '[cm^-1]'})
            ylim([0 0.6])
            subplot1(2);
            plot(VarLambda,AllMus,'LineWidth',2);
            hold on
            plot(MFH.UserData.Wavelengths,SubsetMus,'LineStyle','none','Marker','o');
            text(MFH.UserData.Wavelengths,SubsetMus-2,num2str(SubsetMus,'%.2f'));
            xlabel({'Wavelenghts' '[nm]'})
            ylabel({'mus' '[cm^-1]'})
            ylim([0 15])
            FormattedString = [[ConcNames ScatNames]', repmat({': '},numel(ConcNames)+2,1),num2cell(num2str([squeeze(DataConc(Ypos,Xpos,:));squeeze(ScatParams(Ypos,Xpos,:))]))];
            FormattedString = FormattedString';
            for iw=1:numel(ConcNames)+2
                NewFormattedString{iw}=[FormattedString{:,iw}];
            end
            output_txt = [
                {strcat('X: ',num2str(round(Xpos)))},...
                {strcat('Y: ',num2str(round(Ypos)))},...
                NewFormattedString{:}];
            AddToFigureListStruct(FH,MFH,'side')
            StopWait(parentfigure);
            figure(AncestorFigure);
            MinimizeFFS(AncestorFigure);
        end
        
    end
end