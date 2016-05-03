clear;
clc;
%close all;

B=0.5;                           %B-Field [T]
%E=20*1E3/0.02;                   %E-Field [V/m] 
%lE=0.2;                         %length of electrodes [m]
lB=0.1;                         %length of magnets [m]
l=lB;                                   
%D=.5;                        %drift [m]
ph=0.2;                         %pinhole diameter [mm]
tph=1000;                       %distance target pinhole [mm]
phmagnet=10;                     %distance ph magnet [mm]
%spot=ph*(tph+phmagnet+l*1E3+D*1E3)/tph;   %spot size on CR39 due to pinhole and divergence [mm]

method='classic';
%method='relativistic';


index1=0;
index2=0;
index3=0;

for x=10:10:50
    x
    index1=index1+1;
    E=x*1e3/0.02;
    
    for y=0.1:0.1:0.6
        index2=index2+1;
        lE=y
        
        for z=y+0.1:0.1:1
            index3=index3+1;
            D=z;
            spot=ph*(tph+phmagnet+l*1E3+D*1E3)/tph; %spot size on CR39 due to pinhole and divergence [mm]
    
            over=overlapping(B,E,lE,lB,D,spot,method);

            %over(1,1)                       distance of intersection point C5+ and C6+ to zero point
            %over(2,1)=TRACE(index1,7)/1E6;  energy of C6+ in MeV at intersection point C5+ and C6+ 
            %over(3,1)=distance(index2,1);   distance of intersection point C6+ and proton to zero point
            %over(4,1)=TRACE(index2,7)/1E6;  energy of C6+ in MeV at intersection point C6+ and proton 
            %over(5,1)=TRACE(index2,3)/1E6;  energy of proton in MeV at intersection point C6+ and proton         
            
            over_ana(index3,1)=E;
            over_ana(index3,2)=lE;
            over_ana(index3,3)=D-lE+lB;
            over_ana(index3,4)=E*lE;
            over_ana(index3,5)=round((D-lE+lB)*10);
            over_ana(index3,6)=round(E*lE/(50000));
            over_ana(index3,7)=over(5,1);
            
            surf_y=round((D-lE+lB)*10);
            surf_x=round(E/(10000/0.2));
            surf_z=round(lE/0.1);
            over_surfHC6(surf_y,surf_x,surf_z)=over(5,1); %H+ at interseciton with C6+ 
            over_surfC6H(surf_y,surf_x,surf_z)=over(4,1)/12; %C6+ at intersection with H+
            over_surfC6C5(surf_y,surf_x,surf_z)=over(2,1)/12; %C6+ at intersection with C5+
            over_surfC5C6(surf_y,surf_x,surf_z)=over(6,1)/12; %C5+ at interseciton with C6+
        end
    end
end