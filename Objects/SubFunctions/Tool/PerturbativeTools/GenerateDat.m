function message = GenerateDat(mtoolobj)
RawData = squeeze(mtoolobj.Parent.Data.DatInfo.RawData);
SUBH = mtoolobj.Parent.Data.DatInfo.SUBH;
CH = mtoolobj.Parent.Data.DatInfo.CH;
[r,c]=find(mtoolobj.Parent.Data.Pert.Roi.Shape.createMask);
r = unique(r); c = flip(unique(c));
CH.LoopNum(1) = numel(c);
CH.LoopNum(2) = numel(r);
H = CompileHeader(CH);
[FileName,FilePath,FilterIndex]=uiputfilecustom('.DAT','Save table');
if FilterIndex == 0, return; end
% [FilePath,FileName]=fileparts(mtoolobj.Parent.Data.DataFilePath);
fid_out = fopen(strcat(fullfile(FilePath,FileName)), 'wb');
fwrite(fid_out, H, 'uint8');
for iy = r'
    for ix = c'
        fwrite(fid_out, SUBH(iy,ix,:), 'uint8');
        curve=squeeze(RawData(iy,ix,:));
        fwrite(fid_out, curve, 'uint32');
    end
end
fclose(fid_out);
msgbox({['Dat generated: ',FileName],['Data num: ',num2str(mtoolobj.Parent.Data.Pert.NumData)]},'Done','help')
message = 'Generated DAT';
end