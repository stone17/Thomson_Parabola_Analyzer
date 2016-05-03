clear;
clc;
close all;

B=0.55;                         %B-Field [T]
E=16*1E3/0.02;                  %E-Field [V/m] 
lE=0.4;                        %length of electrodes [m]
lB=0.1;                         %length of magnets [m]
l=lB;                                   
D=0.485;                        %drift [m]

index=0;
for tph=0:20:1000
index=index+1
subindex=0;
for D=0.5:0.1:0.6
subindex=subindex+1;
ph=0.3;                         %pinhole diameter [mm]
%tph=1250;                       %distance target pinhole [mm]
phmagnet=85;                     %distance ph magnet [mm]
diam=ph*(tph+phmagnet+l*1E3+D*1E3)/tph;   %spot size on CR39 due to pinhole and divergence [mm]
e=1.60E-19;                     %[C] electron charge
mC=12*1.67E-27;                 %[kg] carbon nucleon mass (12*proton mass)

a=6;                            %charge
A=12;                            %atomic number

trace=tracer(E,lE,B,lB,D,a,A);  %load trace for specific ion

tracemin=(trace(:,1)-100e6).^2;
[value,index500]=min(tracemin);
tracemin=(trace(:,1)-101e6).^2;
[value,index550]=min(tracemin);

if subindex==1 %difference in distance between 500MeV and 550MeV
    distance0=trace(index500,2)-trace(index550,2);
else
    distance=trace(index500,2)-trace(index550,2)-distance0;
end

if subindex==1 %difference in spotsize
    diam0=diam;
else
    diamdiff=diam-diam0;
end


end
optim(index,1)=tph;
optim(index,2)=diamdiff/distance;
clear diam0 diamdiff distance distance0
end
plot (optim(:,1),optim(:,2));
%plot (iE/1E6,Res) 

%mat(:,1)=iE;
%mat(:,2)=Res;

%save('res_TP1.txt','mat','-ascii')
