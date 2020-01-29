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
         obj.CustomData.Roi = history.roi;
      end
   end
end