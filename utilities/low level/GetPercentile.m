function prcval = GetPercentile(Data,perc)
lowperc = perc(1);
highperc = perc(2);
Data = Data(:);
Data(Data == 0) = NaN;
highprcval = prctile(Data,highperc);
if isnan(highprcval), highprcval = 0; end
lowprcval = prctile(Data,lowperc);
if isnan(lowprcval), lowprcval = 0; end
prcval=[lowprcval,highprcval];
if diff(prcval)==0,highprcval = inf; prcval=[lowprcval,highprcval];end
end