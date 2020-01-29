function message = FixedProfile(mtoolobj,toolname)
dch = datacursormode(mtoolobj.Parent.Figure);
datacursormode on
dch.DisplayStyle = 'window';
dch.UpdateFcn = {@ProfileOnGraph,mtoolobj.Axes,toolname};
message = 'Profile applied';
end
function output_txt=ProfileOnGraph(datacursorobj,~,maxesobj,orientation)
pos = datacursorobj.Position; cpos = pos(1); rpos = pos(2);
mfigobj=mfigure('Name',['Profile ', orientation, ' of ',maxesobj.Name,'. ',maxesobj.Parent.Name],'Category','Profile');
Data = maxesobj.ImageData;
[numr,numc]=size(Data);
output_txt = [...
    {strcat('X: ',num2str(round(cpos)))},...
    {strcat('Y: ',num2str(round(rpos)))},...
    {strcat('Z: ',num2str(Data(rpos,cpos)))}];
delete(findobj(maxesobj.axes,'type','constantline'));
if strcmpi(orientation,'row')
    plot(1:numc,Data(rpos,:));
    yline(maxesobj.axes,rpos,'Color','red');
else
    plot(1:numr,Data(:,cpos));
    xline(maxesobj.axes,cpos,'Color','red');
end
ylim(GetPercentile(Data,[maxesobj.LowPercentile maxesobj.HighPercentile]))
%maxesobj.Parent.Show
end