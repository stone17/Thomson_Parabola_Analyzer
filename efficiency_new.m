%function [eff]=efficiency(E_laser,t_ph,diam,angle)
clear all
clc

fid = fopen('lastpath.txt','r');
pname=(fread(fid,'*char'))';
fclose(fid)
 
[file,path]=uigetfile('*.txt','Load reference',pname);
datei=strcat(path,file);
spec=load(datei);
filename=datei(1:length(datei)-4);
parfile=[filename '_par.txt'];
par=load(parfile);

E_laser=100;
angle=10.0;

e=1.60217648740e-19;                                %electron charge [C]
diam=par(7)*1e-6;                                   %pinhole diameter [m]
t_ph=1250*1e-3;                                     %distance target pinhole [m]
msr=(diam/2)^2*pi/t_ph^2*1E3;                       %solid angle captured by TP [msr]
%total=(tan(angle/360*2*pi)*t_ph)^2*pi/t_ph^2*1e3;   %total solid angle [msr]
total=4*pi*sin(angle/2/360*2*pi)^2*1e3

figure
semilogy (spec(:,1),spec(:,4))

[x,y]=ginput(2);

[value1,index1]=min((spec(:,1)-x(1)).^2);
[value2,index2]=min((spec(:,1)-x(2)).^2);

hold all
semilogy (spec(index1,1),spec(index1,4),'Linewidth',2,'color','r')
semilogy (spec(index2,1),spec(index2,4),'Linewidth',2,'color','r')
hold off

if index1<index2
    max_index=index2;
    min_index=index1;
else
    max_index=index1;
    min_index=index2;
end

E_all=0;
Ni_TP=0;
N=sum(spec(min_index:max_index,5));

for a=min_index:max_index
    E=spec(a,1);               %interval of E in MeV 
    Ni=spec(a,5);              %particles in interval per msr
    Ni_TP=Ni_TP+Ni;
    E_all=E_all+Ni*E;          %total Energy of N particles per msr
end

E_Joule_TP=E_all*e*1e6                              %Energy on TP [J]
E_Joule_total=E_all*e*total/msr*1e6                 %total Energy over given angle [J]

N_total=N*total/msr                                 %particles in solid angle
N                                                   %particles in TP

dE_full=spec(min_index,1)-spec(max_index,1)         %energy intervall

E_Joule_TP/E_laser*100                              %in percent
E_Joule_total/E_laser*100                           %in percent

