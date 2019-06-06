function StatS = GetStatistics(Data)
StatS.Counts = sum(Data);
[Width,Baricentre,MaxPos,MaxVal]=CalcWidth(Data,0.5);
StatS.Width = Width;
StatS.Baricentre = Baricentre;
StatS.MaxPos = MaxPos;
StatS.MaxVal = MaxVal;
end