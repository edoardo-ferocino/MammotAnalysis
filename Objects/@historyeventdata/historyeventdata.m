classdef (ConstructOnLoad) historyeventdata < event.EventData
    properties
        CustomData;
    end
    
    methods
        function obj = historyeventdata(history)
            obj.CustomData.Data = history.data;
            obj.CustomData.Message = {history.message};
            obj.CustomData.ToolName = history.toolname;
            if ~isfield(history,'roi')
                history.roi = [];
            end
            if ~isfield(history,'PickData')
                history.PickData = [];
            end
            obj.CustomData.Roi = history.roi;
            obj.CustomData.PickData = history.PickData;
        end
    end
end