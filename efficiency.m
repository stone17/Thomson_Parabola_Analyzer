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

E=spec(:,1);
%spec(:,2)=spec(:,2)./100;
f=spec(:,4);
E_laser=60;
angle=20;

e=1.60217648740e-19;                                %elctron charge [C]
diam=par(7)*1e-6;                                   %pinhole diameter [m]
t_ph=20*1e-3;                                     %distance target pinhole [m]
msr=(diam/2)^2*pi/t_ph^2*1E3;                       %solid angle captured by TP [msr]
total=(tan(angle/360*2*pi)*t_ph)^2*pi/t_ph^2*1e3;   %total solid angle [msr]

figure
semilogy (E,f)

[x,y]=ginput(2);

t=[min(f):(min(f)+max(f))/100:max(f)];

hold all
semilogy (x(1)+0*t,t)
semilogy (x(2)+0*t,t)
%plot(x(1)+0*t,t)
%plot(x(2)+0*t,t)
hold off

[max_value,max_index]=min((E-x(1)).^2);
[min_value,min_index]=min((E-x(2)).^2);

if max_index<min_index
    E=E(max_index:min_index);
    f=f(max_index:min_index);
else
    E=E(min_index:max_index);
    f=f(min_index:max_index);
end

n=length(E);

E_all=0;
N=0;

for a=1:n-1
    Ni=0;
    dE=sqrt((E(a)-E(a+1))^2);   %interval of E in MeV
    Ea=(E(a)+E(a+1))/2;         %average Energy of interval    
    Ni=(f(a)+f(a+1))/2*dE;      %particles in interval per msr
    E_all=E_all+Ni*Ea;          %total Energy of N particles per msr
    N=N+Ni;                     %particles in interval per msr
end

E_Joule_TP=E_all*e*1e6*msr                          %Energy on TP [J]
E_Joule_total=E_all*e*total*1e6                       %total Energy over given angle [J]


N_TP=N*msr                                              %particles in TP
N_total=N*total                                        %particles in solid angle


dE=E(1)-E(length(E))                                %energy intervall

E_Joule_TP/E_laser*100                              %in percent
E_Joule_total/E_laser*100                           %in percent

