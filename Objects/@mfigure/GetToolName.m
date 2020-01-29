function [completetoolname,varargout] = GetToolName(mfigobj,menuobj)
% Get tool name from an obj tag
toolname=split(menuobj.Tag,mfigobj.spacer);
toolname = lower(toolname(3:end));
splittedtoolname = toolname; 
completetoolname = strcat(toolname{:});
varargout{1}=splittedtoolname;
end
