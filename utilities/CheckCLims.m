function outputlims = CheckCLims(inputlims)
    outputlims = inputlims;
    if(inputlims(2)<inputlims(1))
        outputlims = flip(inputlims);
    end
end