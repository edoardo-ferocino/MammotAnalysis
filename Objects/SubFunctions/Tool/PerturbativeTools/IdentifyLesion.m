function message = IdentifyLesion(mtoolobj,type)
mroiobj = mtoolobj.Roi(vertcat(mtoolobj.Roi.Selected));
if ~all(strcmpi({mroiobj.Name},'Lesion'))
    DisplayError('No roi defined as "Lesion"','Mark a roi as "Lesion"');
    return
end
nroi = numel(mroiobj);
for ir = 1:nroi
    if sum(mroiobj(ir).Shape.createMask,'all') > 1024
        DisplayError('Lesion roi too big','Reduce below 1024 points');
        return
    end
    LesionData = mroiobj(ir).Shape.createMask.*mtoolobj.Axes.ImageData;
    LesionData(LesionData==0)=nan;
    [val,pos]=min(LesionData,[],'all','omitnan','linear');
    [r,c]=ind2sub(size(LesionData),pos);
    LesPos = [r c];
    if strcmpi(type,'auto')
        Draggable = 'off';
    else
        Draggable = 'on';
    end
    mfigobj = mfigure('Name',['Identify lesion - ' mtoolobj.Parent.Data.FileName],'Category','IdentifyLesion');
    sh=surf(LesionData); colormap pink
    sh.Parent.YAxis.Direction = 'reverse';
    dch=datacursormode(gcf);
    dth = dch.createDatatip(sh);
    dth.Position = [flip(LesPos) val];
    dth.Draggable = Draggable;
    delete(findobj(mfigobj.Figure,'tag','ok'));
    if strcmpi(type,'manual')
       uicontrol(mfigobj.Figure,'Style','pushbutton','String','Ok','Units','normalized','Position',[0.95 0 0.05 0.05],'Callback',{@SetMin,mtoolobj,dth},'tag','ok');
    else
       delete(findobj(mfigobj.Figure,'tag','ok'));
       mtoolobj.Parent.Data.Pert.LesionPosition = LesPos;
    end
    mtoolobj.Parent.Data.Pert.NumData = sum(mroiobj(ir).Shape.createMask,'all');
    mtoolobj.Parent.Data.Pert.Roi = mroiobj(ir); 
end
message = 'Identified lesion';
end
function SetMin(~,~,mtoolobj,dch)
    LesPos = dch.Position(1:2);
    mtoolobj.Parent.Data.Pert.LesionPosition = flip(LesPos);
    msgbox('Done!');
end