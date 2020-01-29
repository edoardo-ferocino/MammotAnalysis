function [completetoolname,varargout] = GetToolName(mtoolobj,menuobj)
% Get tool name from an obj tag
toolname=split(menuobj.Tag,mtoolobj.Parent.spacer);
toolname = lower(toolname(3:end));
splittedtoolname = toolname; 
completetoolname = strcat(toolname{:});
varargout{1}=splittedtoolname;
end
