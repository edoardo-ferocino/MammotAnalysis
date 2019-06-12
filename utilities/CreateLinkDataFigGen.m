function [FH,CH,CBH]=CreateLinkDataFigGen(MFH,varargin)
if nargin>1
    parentfigure = varargin{1};
else
    parentfigure = 0;
end
FH = CreateOrFindFig('Link Figures','NumberTitle','off','Toolbar','None','MenuBar','none','Units','Normalized');
clf(FH);
FH.UserData.FigCategory = 'LinkFigures';
actualnameslist = MFH.UserData.ListFigures.String(~contains(MFH.UserData.ListFigures.String,'Select filters'));
numfig = numel(actualnameslist);
PCH = CreateContainer(FH,'BorderType','none','Units','Normalized','Position',[0 0 0.95 1]);%,'BorderType','none');
SLH = uicontrol(FH,'Style','slider','Value',0,'Units','normalized','Position',[PCH.Position(3) 0 0.05 1],'Callback',{@MoveContainer,PCH});
ContainerWidth = 0.1;
SLH.Min = 0; SLH.Max = numfig*ContainerWidth; SLH.Value = SLH.Max;
for ifigs = 1:numfig
    CH(ifigs) = CreateContainer(PCH,'BorderType','none','Units','Normalized','Position',[0 1-(ContainerWidth)*(ifigs) 1 ContainerWidth]);%,'BorderType','none');
    CH(ifigs).UserData.OrigPosition = CH(ifigs).Position;
    CreateEdit(CH(ifigs),'String',actualnameslist{ifigs},'HorizontalAlignment','Left',...
        'Units','Normalized','OuterPosition',[0 0 0.7 1]);
    CBH(ifigs) = CreateCheckBox(CH(ifigs),'String','Link','Units','Normalized','Position',[0.7 0 0.1 1]);
%     if ishandle(parentfigure)
%         if(numel(parentfigure.Name)>=numel(actualnameslist{ifigs}))
%             if strcmpi(actualnameslist{ifigs}(1:strfind(actualnameslist{ifigs},'-')-1)...
%                     ,parentfigure.Name((1:strfind(actualnameslist{ifigs},'-')-1)))
%                 CBH(ifigs).Value = true;
%             end
%         end
%     end
end
    function MoveContainer(SH,~,PCH)
        Shift = (SH.Max-SH.Value);
        for ich = 1:numel(PCH.Children)
            PCH.Children(ich).Position(2) = PCH.Children(ich).UserData.OrigPosition(2)+Shift;
        end
    end
end