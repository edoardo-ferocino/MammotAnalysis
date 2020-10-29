function message = ImProfile(mtoolobj)
axes(mtoolobj.Axes.axes);
improfile
mfigure(gcf,'tag',strcat('improfile',mtoolobj.Axes.Name),'Name',['Profile ',mtoolobj.Axes.Name]);
message = 'Applied improfile';
end