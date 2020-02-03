function ApplyFilterTool(mtoolobj,completetoolname,toolname)
nobjs = numel(mtoolobj);
dosetstatus = false;
dosethistory = true;
for iobj = 1:nobjs
    maxesactvobj = mtoolobj(iobj).Axes;
    mtoolactvobj = mtoolobj(iobj);
    data = maxesactvobj.ImageData;
    switch toolname{1}
        case 'median'
            data = medfilt2(data,[3 3]);
        case 'weiner'
            data = wiener2(data,[3 3]);
        case 'gaussian'
            data = imgaussfilt(data);
        case 'diffuse'
            data = imdiffusefilt(data);
        case 'clearborder'
            data = imclearborder(data,8);
        case 'nonlocalmean'
            data = imnlmfilt(data);
        case 'medianmask'
            data = MedianMask(data,maxesactvobj);
    end
    maxesactvobj.ImageData = data;
    maxesactvobj.CLim = GetPercentile(maxesactvobj.ImageData,[maxesactvobj.LowPercentile maxesactvobj.HighPercentile]);
    if dosetstatus == true
        mtoolactvobj.Status.(completetoolname) = 1;
    end
    if dosethistory == true
        history.roi = mtoolactvobj.Roi;
        history.data = data;
        history.toolname = completetoolname;
        history.message = ['Applied ', toolname{1}, ' filter'];
        notify(maxesactvobj,'ToolApplied',historyeventdata(history));
    end
end

end