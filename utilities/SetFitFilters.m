function SetFitFilters(Fit,FitFilePath,AutoRun)
[~,FileName,~]=fileparts(FitFilePath);
FigFilterName = ['Select filters - ' FileName];
mfigobj = mfigure('Name',FigFilterName,'NumberTitle','off','Toolbar','None','MenuBar','none','Category','Filters');
delete(setdiff(findobj(mfigobj.Figure,'type','uicontrol','-or','type','uipanel'),mfigobj.OtherFiguresSelectedH));
Fit.FileName = FileName;
Filters = Fit.Filters;
poph=matlab.ui.control.UIControl.empty(numel(Filters),0);
for ifil = 1:numel(Filters)
    ch = uipanel(mfigobj.Figure,'Units','pixels','Position',[0 mfigobj.Figure.Position(4)/numel(Filters)*(ifil-1) mfigobj.Figure.Position(3) mfigobj.Figure.Position(4)/numel(Filters)],'BorderType','none');
    poph(ifil) = uicontrol(ch,'Style','popupmenu','Units','Normalized','String',Filters(ifil).Categories,...
        'Position',[0 0 0.3 0.8]);
    uicontrol(ch,'Style','edit','Units','Normalized','Position',...
        [0.4 0.3 0.3 0.5],'String',Filters(ifil).Name,'HorizontalAlignment','left');
end
uicontrol(mfigobj.Figure,'Style','pushbutton','Units','Normalized','Position',[0.92 0.92 0.08 0.08],'String','Run','Callback',{@RunFit,poph,Fit,mfigobj});
mfigobj.Show('off');
if AutoRun
  RunFit([],[],poph,Fit,mfigobj);
end
end