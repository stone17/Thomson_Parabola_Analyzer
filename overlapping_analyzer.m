clear;
clc;
%close all;

B=0.91;                           %B-Field [T]
E=40*1E3/0.02;                   %E-Field [V/m] 
lE=0.7;                         %length of electrodes [m]
lB=0.2;                         %length of magnets [m]
l=lB;                                   
D=.5;                        %drift [m]
ph=0.2;                         %pinhole diameter [mm]
tph=1000;                       %distance target pinhole [mm]
phmagnet=10;                     %distance ph magnet [mm]
spot=ph*(tph+phmagnet+l*1E3+D*1E3)/tph;   %spot size on CR39 due to pinhole and divergence [mm]

%method='classic';
method='relativistic';


index1=0;
for x=40:5:40
    index1=index1+1
    E=x*1e3/0.02
    %spot=ph*(tph+phmagnet+l*1E3+D*1E3)/tph; %spot size on CR39 due to pinhole and divergence [mm]
    
    over=overlapping(B,E,lE,lB,D,spot,method);

    %over(1,1)                       distance of intersection point C5+ and C6+ to zero point
    %over(2,1)=TRACE(index1,7)/1E6;  energy of C6+ in MeV at intersection point C5+ and C6+ 
    %over(3,1)=distance(index2,1);   distance of intersection point C6+ and proton to zero point
    %over(4,1)=TRACE(index2,7)/1E6;  energy of C6+ in MeV at intersection point C6+ and proton 
    %over(5,1)=TRACE(index2,3)/1E6;  energy of proton in MeV at intersection point C6+ and proton
    
    over_ana(index1,1)=x;
    over_ana(index1,2)=over(2,1)/12; %C6+ at intersection with C5+
    over_ana(index1,3)=over(4,1)/12; %C6+ at intersection with H+
    over_ana(index1,4)=over(5,1); %H+ at interseciton with C6+ 
    over_ana(index1,5)=over(6,1)/12; %C5+ at interseciton with C6+ 
    
end

figure
%plot(over_ana(:,1),over_ana(:,2),'color','g')
hold on
plot(over_ana(:,1),over_ana(:,3),'color','r')
plot(over_ana(:,1),over_ana(:,4),'color','b')
%plot(over_ana(:,1),over_ana(:,5),'color','m')
%hold off


e=1.60E-19;     %[C] electron charge
Ex=5:5:40
E=Ex.*1e3./0.02
dD=D-lE+lB;
Rq=(12/12+6/12)/(12/12-6/12);

%Ek_p=1*e*E.*lE.*(dD+0.5*lE)./(spot/1e3*Rq);
Ek_p=e*E.*lE.*(dD+0.5.*lE)./(spot/1e3*Rq);
Ek_C=6*Ek_p/12;

Ek_p=Ek_p./1e6/e;
Ek_C=Ek_C./1e6/e;

plot(Ex,Ek_p,'x','color','b')
plot(Ex,Ek_C,'x','color','r')
hold off

save('over.txt','over_ana','-ascii')
