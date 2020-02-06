classdef mtool < handle
    %mtool Tool Class for the MammotAnalysis interface
    properties (SetAccess = immutable)
        Parent mfigure;             % mfigure as parent
        Axes maxes;                 % Axes object
    end
    properties (Hidden = true)
        DefaultStatus;              % Status of tools
        Status;                     % Actual status of tools
    end
    properties
        Roi mroi;                   % Roi obj
    end
    properties (Dependent)
        nRoi;                       % nRoi
    end
    methods (Access = ?maxes)
        function mtoolobj = mtool(maxesobj,mfigobj)
            %Creation of tool obj
            mtoolobj.Parent = mfigobj;
            mtoolobj.Axes = maxesobj;
            for im = 1:mfigobj.nSubMenu
                toolname = mtoolobj.GetToolName(mfigobj.SubMenu(im));
                mtoolobj.DefaultStatus.(toolname) = 0;
            end
            mtoolobj.Status = mtoolobj.DefaultStatus;
        end
    end
    methods
        function out = get.nRoi(mtoolobj)           % get number of rois
            out = numel(mtoolobj.Roi);
        end
        function Apply(mtoolobjs,menuobj)
            %Method for application of tools
            [completetoolname,splittedtoolname] = mtoolobjs(1).GetToolName(menuobj);
            switch splittedtoolname{1}
                case 'filter'
                    ApplyFilterTool(mtoolobjs,completetoolname,splittedtoolname(2:end));
                case 'drawing'
                    ApplyOverlapTool(mtoolobjs,completetoolname,splittedtoolname(2:end));
                case 'profile'
                    ApplyProfileTool(mtoolobjs,completetoolname,splittedtoolname(2:end));
                case 'trimmer'
                case 'shift'
                case 'colorbar'
                    ApplyColorbarTool(mtoolobjs,completetoolname,splittedtoolname(2:end));
                case 'measure'
                    ApplyMeasureTool(mtoolobjs,completetoolname,splittedtoolname(2:end));
                case 'save'
                case 'pickonimage'
                    ApplyPickTool(mtoolobjs,completetoolname,splittedtoolname(2:end));
                case {'roi','border'}
                    ApplyRoiTool(mtoolobjs,completetoolname,splittedtoolname(2:end));
                case 'history'
                    ApplyHistoryTool(mtoolobjs,completetoolname,splittedtoolname(2:end));
                case 'compare'
                    ApplyCompareTool(mtoolobjs,completetoolname,splittedtoolname(2:end));
                case 'gate'
                    ApplyGateTool(mtoolobjs,completetoolname,splittedtoolname(2:end));
                case 'figures'
                    ApplyFiguresTool(mtoolobjs,completetoolname,splittedtoolname(2:end));
                case 'perturbative'
                    ApplyPerturbativeTool(mtoolobjs,completetoolname,splittedtoolname(2:end));
            end
            notify(mtoolobjs(1).Parent,'AxesSelection');
        end
        function Remove(mtoolobjs,menuobj,varargin)
            %Method for application of tools
            [completetoolname,splittedtoolname] = mtoolobjs(1).GetToolName(menuobj);
            switch splittedtoolname{1}
                case 'filter'
                case 'overlap'
                case 'profile'
                    RemoveProfileTool(mtoolobjs,completetoolname,splittedtoolname(2:end));
                case 'pickonimage'
                    RemovePickTool(mtoolobjs,completetoolname,splittedtoolname(2:end));
                case 'border'
                case 'trimmer'
                case 'shift'
                case 'colorbar'
                    RemoveColorbarTool(mtoolobjs,completetoolname,splittedtoolname(2:end));
                case 'measure'
                    RemoveMeasureTool(mtoolobjs,completetoolname,splittedtoolname(2:end));
                case 'save'
                case 'spectrum'
                case 'roi'
                    RemoveRoiTool(mtoolobjs,completetoolname,splittedtoolname(2:end),varargin{:});
                case 'history'
                case 'compare'
                case 'select'
                case 'gate'
                    RemoveGateTool(mtoolobjs,completetoolname,splittedtoolname(2:end));
            end
            notify(mtoolobjs(1).Parent,'AxesSelection');
        end
    end
    methods (Hidden = true)
       [completetoolname,varargout] = GetToolName(mtoolobj,menuobj);
    end
end

