function prcval = GetPercentile(Data,perc)
Data = Data(:);
Data(Data == 0) = NaN;
prcval = prctile(Data,perc);
if isnan(prcval), prcval = 0; end
end