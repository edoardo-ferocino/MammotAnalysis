classdef mroi < handle
    %mroi Roi Class for Mammot Analysis interface
    events
        SyncronousRoiMovement
    end
    properties
        RoiValues;          %roi stats
        CopiedRoi=false;       %roi copied
        Name = char.empty;               % Name of the Roi
    end
    properties (Dependent)
        Selected;           % true if roi is selected
    end
    properties (SetAccess = immutable)
        Tool mtool;         % mtoolobj
        Shape;              % handle for shape
        ID;                 % unique identifier
        Type;               % if roi or if border
    end
    properties (Hidden = true)
        SyncRoiMoveListenerHandle;
    end
    methods
        function mroiobj = mroi(mtoolobj,shape,type,shape2copy)
            %Creator of mroiobj
            persistent ID;
            mroiobj.Tool=mtoolobj;
            maxesobj = mtoolobj.Axes;
            if strcmpi(shape,'entireimage')
                mroiobj.Name = 'Entire image';
                shape = 'Rectangle';
                shape2copy.Position = [0.5 0.5 size(maxesobj.ImageData,2) size(maxesobj.ImageData,1)];
            end
            shape(1) = upper(shape(1));
            Shape = images.roi.(shape)(maxesobj.axes);
            Shape.FaceAlpha = 0;
            Shape.Color = rand(1,3);
            if strcmpi(type,'border')
                Shape.Color = 'blue';
                Shape.StripeColor = 'yellow';
            elseif strcmpi(type,'gate')
                Shape.Color = 'magenta';
            end
            Shape.SelectedColor = 'red';
            if all(Shape.Color == Shape.SelectedColor)
                Shape.Color = rand(1,3);
            end
            if isempty(ID)
                ID = 1;
            else
                ID = ID+1;
            end
            mroiobj.ID = ID;
            if isempty(shape2copy)
                addlistener(Shape,'DrawingFinished',@(src,event)mroiobj.GetData(src,event,maxesobj,true));
                draw(Shape)
            else
                Shape.Position = shape2copy.Position;
                mroiobj.GetData(Shape,[],maxesobj,true);
            end
            addlistener(Shape,'ROIMoved',@(src,event)mroiobj.GetData(src,event,maxesobj,true));
            addlistener(Shape,'ObjectBeingDestroyed',@(src,event)mroiobj.CleanToolRoiState(src,event,maxesobj));
            mroiobj.Shape = Shape;
            mroiobj.Type = type;
            if strcmpi(mroiobj.Name,'Entire image')
               uistack(Shape,'bottom');
            end
        end
    end
    methods (Access = public)
        function GetData(mroiobj,shapeobj,~,maxesobj,isnotify)
            %Get stats within roi
            shapeobj.Selected = false;
            ImageData = maxesobj.ImageData;
            RoiData = ImageData.*shapeobj.createMask;
            OutRoiData = ImageData.*(~shapeobj.createMask);
            RoiData(RoiData==0) = NaN;
            OutRoiData(RoiData==0) = NaN;
            Roi.ID = mroiobj.ID;
            Roi.FileName = maxesobj.Parent.Data.FileName;
            Roi.FigureName = maxesobj.Parent.Name;
            Roi.AxesName = maxesobj.Name;
            Roi.Name = mroiobj.Name;
            Roi.Mean = mean(RoiData(:),'omitnan');
            Roi.Points = sum(isfinite(RoiData(:))&RoiData(:)~=0);
            Roi.Median = median(RoiData(:),'omitnan');
            Roi.Std = std(RoiData(:),'omitnan');
            Roi.CV = Roi.Std./Roi.Mean; Roi.CV(isnan(Roi.CV)) =0;
            Roi.Max = max(RoiData(:));
            Roi.Min = min(RoiData(:));
            Roi.OutMean = mean(OutRoiData(:),'omitnan');
            Roi.OutPoints = sum(isfinite(OutRoiData(:))&OutRoiData(:)~=0);
            Roi.OutMedian = median(OutRoiData(:),'omitnan');
            Roi.OutStd = std(OutRoiData(:),'omitnan');
            Roi.OutCV = Roi.OutStd./Roi.OutMean; Roi.OutCV(isnan(Roi.OutCV)) =0;
            Roi.OutMax = max(OutRoiData(:));
            Roi.OutMin = min(OutRoiData(:));
            Labels = {'Session' 'Breast' 'View' 'Patient'};
            if isfield(mroiobj.Tool.Parent.Data,'Fit')
               if ~strcmpi(mroiobj.Tool.Parent.Data.Fit.Type,'spectral')
                 Roi.Lambda = str2double(cell2mat(regexpi(maxesobj.Name,'(\d)+','match')));
                 if contains(maxesobj.Name,'\mu_{s}''')
                     Roi.FitType = 'Mus';
                 else
                     Roi.FitType = 'Mua';
                 end
               else
                 Roi.Lambda = 0;  
                 Roi.FitType = 'Spectral';
               end
               for il = 1:numel(Labels)
                   logicalpos = strcmpi({mroiobj.Tool.Parent.Data.Fit.Filters.Name},Labels(il));
                   if any(logicalpos)
                       Roi.(Labels{il})=mroiobj.Tool.Parent.Data.Fit.Filters(logicalpos).Categories{2};
                   end
               end
            else
               for il = 1:numel(Labels)
                   Roi.(Labels{il}) = 'none';
               end
               Roi.Lambda = 0; 
               Roi.FitType = 'none';
            end
            Roi.Position = strjoin(string(shapeobj.Position),',');
            mroiobj.RoiValues = Roi;
            if isnotify
                notify(mroiobj,'SyncronousRoiMovement');
            end
        end
    end
    methods (Hidden = true)
        function CleanToolRoiState(mroiobj,~,~,maxesobj)
            maxesobj.Tool.Roi(vertcat(maxesobj.Tool.Roi.ID)==mroiobj.ID)=[];
        end
    end
    methods
        function status=get.Selected(mroiobj)
            status=mroiobj.Shape.Selected;
        end
        function set.Selected(mroiobj,status)
            mroiobj.Shape.Selected = status;
        end
    end
end