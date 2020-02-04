function message = DeleteBorder(mtoolobj,type)
message = 'Error. No roi selected. Tool not applied';
selectedrois = vertcat(mtoolobj.Roi.Selected);
if sum(selectedrois)==0, return, end
maxesobj = mtoolobj.Axes;

IDselectedrois =  {num2str([mtoolobj.Roi(selectedrois).ID],'%d,')};
IDselectedrois = IDselectedrois{:};IDselectedrois(end)=[];
selectedrois=find(selectedrois);
for is = 1:numel(selectedrois)
    if strcmpi(type,'external')
        mtoolobj.Axes.ImageData=mtoolobj.Axes.ImageData.*mtoolobj.Roi(selectedrois(is)).Shape.createMask;
    end
    if strcmpi(type,'internal')
        mtoolobj.Axes.ImageData=mtoolobj.Axes.ImageData.*not(mtoolobj.Roi(selectedrois(is)).Shape.createMask);
    end
    mtoolobj.Roi(selectedrois(is)).Selected = false;
    if isfield(maxesobj.Parent.Data,'PickData')
        lambda = regexpi(maxesobj.Name,'\lambda\s=*\s(\d)+','tokens');
        channel = regexpi(maxesobj.Name,'Channel ([0-9]?)','tokens');
        if ~isempty(lambda)
            lambda=lambda{1};lambda=lambda{1};lambda=str2double(lambda);
            if strcmpi(type,'external')
                maxesobj.Parent.Data.PickData(maxesobj.Parent.Wavelengths==lambda).SummedChannelsData = ...
                    maxesobj.Parent.Data.PickData(maxesobj.Parent.Wavelengths==lambda).SummedChannelsData.*(mtoolobj.Roi(selectedrois(is)).Shape.createMask);
            else
                maxesobj.Parent.Data.PickData(maxesobj.Parent.Wavelengths==lambda).SummedChannelsData = ...
                    maxesobj.Parent.Data.PickData(maxesobj.Parent.Wavelengths==lambda).SummedChannelsData.*not(mtoolobj.Roi(selectedrois(is)).Shape.createMask);
            end
        elseif ~isempty(channel)
            channel=channel{1};channel=channel{1};channel=str2double(channel);
            if strcmpi(type,'external')
                maxesobj.Parent.Data.PickData(:,:,channel,:)= ...
                    maxesobj.Parent.Data.PickData(:,:,channel,:).*(mtoolobj.Roi(selectedrois(is)).Shape.createMask);
            else
                maxesobj.Parent.Data.PickData(:,:,channel,:) = ...
                    maxesobj.Parent.Data.PickData(:,:,channel,:).*not(mtoolobj.Roi(selectedrois(is)).Shape.createMask);
            end
        else
            if strcmpi(type,'external')
                maxesobj.Parent.Data.PickData = ...
                    maxesobj.Parent.Data.PickData.*(mtoolobj.Roi(selectedrois(is)).Shape.createMask);
            else
                maxesobj.Parent.Data.PickData = ...
                    maxesobj.Parent.Data.PickData.*not(mtoolobj.Roi(selectedrois(is)).Shape.createMask);
            end
        end
    end
    
end
mtoolobj.Axes.CLim = GetPercentile(mtoolobj.Axes.ImageData,[mtoolobj.Axes.LowPercentile mtoolobj.Axes.HighPercentile]);
message = ['Delete tool applied to ROI ',IDselectedrois];
end