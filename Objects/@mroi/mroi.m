classdef mroi < handle
    %mroi Roi Class for Mammot Analysis interface
    events
        SyncronousRoiMovement
    end
    properties
        RoiValues;          %roi stats
        CopiedRoi=false;       %roi copied
        Name = char.empty;  % Name of the Roi
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
            axh=maxesobj.axes;
            if strcmpi(shape,'entireimage')
                shape = 'Rectangle';
                shape2copy.Position = [0.5 0.5 size(maxesobj.ImageData,2) size(maxesobj.ImageData,1)];
            end
            shape(1) = upper(shape(1));
            Shape = images.roi.(shape)(axh);
            Shape.FaceAlpha = 0;
            Shape.Color = rand(1,3);
            if strcmpi(type,'border')
                Shape.Color = 'blue';
                Shape.StripeColor = 'yellow';
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
                addlistener(Shape,'DrawingFinished',@(src,event)mroiobj.GetData(src,event,maxesobj));
                draw(Shape)
            else
                Shape.Position = shape2copy.Position;
                mroiobj.GetData(Shape,[],maxesobj);
            end
            addlistener(Shape,'ROIMoved',@(src,event)mroiobj.GetData(src,event,maxesobj));
            addlistener(Shape,'ObjectBeingDestroyed',@(src,event)mroiobj.CleanToolRoiState(src,event,maxesobj));
            mroiobj.Shape = Shape;
            mroiobj.Type = type;
        end
    end
    methods (Access = private)
        function GetData(mroiobj,shapeobj,~,maxesobj)
            %Get stats within roi
            shapeobj.Selected = false;
            ImageData = maxesobj.ImageData;
            RoiData = ImageData.*shapeobj.createMask;
            RoiData(RoiData==0) = NaN;
            Roi.ID = mroiobj.ID;
            Roi.FigureName = maxesobj.Parent.Name;
            Roi.AxesName = maxesobj.Name;
            Roi.Name = mroiobj.Name;
            Roi.Mean = mean(RoiData(:),'omitnan');
            Roi.Points = sum(isfinite(RoiData(:)));
            Roi.Median = median(RoiData(:),'omitnan');
            Roi.Std = std(RoiData(:),'omitnan');
            Roi.CV = Roi.Std./Roi.Mean; Roi.CV(isnan(Roi.CV)) =0;
            Roi.Max = max(RoiData(:));
            Roi.Min = min(RoiData(:));
            mroiobj.RoiValues = Roi;
            notify(mroiobj,'SyncronousRoiMovement');
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