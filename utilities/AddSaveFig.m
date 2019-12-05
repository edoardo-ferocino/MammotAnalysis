function AddSaveFig(parentfigure)
MenuName = 'Save Figure';
if isempty(parentfigure.UIContextMenu)
    cmh = uicontextmenu(parentfigure);
    parentfigure.UIContextMenu = cmh;
else
    cmh = parentfigure.UIContextMenu;
end
uimenu(cmh,'Label',MenuName,'CallBack',{@SaveFig});

    function SaveFig(~,~)
        StartWait(parentfigure);
        PathName =uigetdircustom('Select destination');
        if PathName == 0, StopWait(gcf); return, end
        FullPath = fullfile(PathName,parentfigure.Name);
        warning off
        figh = copyfig(parentfigure);
        allchildren = findobj(figh,'Parent',nfh);
        except = findobj(figh,'type','axes');
        delete(setdiff(allchildren, except));
        figure(figh);
        axh= findobj(figh,'type','axes');
        for iaxh = 1:numel(axh)
            axh(iaxh).Title = [];
            axh(iaxh).UserData = [];
            axh(iaxh).Children.UserData = [];
        end
        reset(figh)
        colormap pink
        save_figure(FullPath,figh,'-png','-pdf');
        delete(figh);
        %         figh = copyfig(parentfigure);
        %         figh.reset;
        %         figure(figh);
        %         SetAxesAppeareance(findobj(figh,'type','axes'));
        %         delete(findobj(figh,'type','colorbar'));
        %         axh= findobj(figh,'type','axes');
        %         for iaxh = 1:numel(axh)
        %             TempName = [FullPath '-' axh(iaxh).Title.String];
        %             axh(iaxh).Title = [];
        %             FFS(99+iaxh); subh=subplot1(1,1); subplot1(1);
        %             imagesc(subh,axh(iaxh).Children.CData,[0 GetPercentile(axh(iaxh).Children.CData,95)]);
        %             subh.YDir = 'reverse';
        %             axis image; colormap pink, shading interp;
        %             save_figure(TempName,FFS(99+iaxh),'-png','-pdf');
        %             delete(FFS(99+iaxh));
        %         end
        %       delete(figh);
        warning on
        msgbox('Figure saved','Success','Help');
        StopWait(parentfigure);
    end

end