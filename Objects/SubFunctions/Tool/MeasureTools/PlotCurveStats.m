function PlotCurveStats(Stats)
plotstatsmfigobj=mfigure('Name','Stats','Tag','PlotCurveStats','Uifigure','true','Category','CurveStats');
delete(setdiff(findobj(plotstatsmfigobj.Figure),vertcat(plotstatsmfigobj.Figure,plotstatsmfigobj.Graphical.MultiSelFigPanel,plotstatsmfigobj.Graphical.MultiSelAxPanel)));
Stats = cell2mat(Stats);
Table = struct2table(Stats,'AsArray',true);
uitable(plotstatsmfigobj.Figure,'data',rows2vars(Table),'Position',[0 0 plotstatsmfigobj.Figure.Position(3) 220]); 
plotstatsmfigobj.Figure.Position(3) = 900;
plotstatsmfigobj.Figure.Position(4) = 220;
end