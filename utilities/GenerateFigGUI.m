prevpath = pwd; 
cd('../');
save('temp.mat','prevpath');
run('MammotAnalysis');
savefig('MammotAnalysis')
close
load('temp.mat','prevpath');
delete('temp.mat');
cd(prevpath);
clear
