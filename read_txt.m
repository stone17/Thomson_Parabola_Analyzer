clc
clear all

if exist('lastpath.txt')
fid = fopen('lastpath.txt','r');
s=(fread(fid,'*char'))'
fclose(fid)
end