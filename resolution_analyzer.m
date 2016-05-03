clear;
clc;
%close all;

B=0.5;                         %B-Field [T]
E=30*1E3/0.02;                  %E-Field [V/m] 
lE=0.1;                         %length of electrodes [m]
lB=0.1;                         %length of magnets [m]
l=lB;                                   
D=0.5;                        %drift [m]
a=1;                            %charge
A=1;                           %atomic number
ph=0.3;                         %pinhole diameter [mm]
tph=1000;                       %distance target pinhole [mm]
phmagnet=20;                     %distance ph magnet [mm]


%method='classic';
method='relativistic';
method='rk';


index1=0;
for x=0.1:0.05:.5
    index1=index1+1
    D=x;
    
    spot=ph*(tph+phmagnet+l*1E3+D*1E3)/tph;   %spot size on CR39 due to pinhole and divergence [mm]
    res=resolution(E,lE,B,lB,D,a,A,spot,method);
    
    Ei=[round(min(res(:,1))):1:round(max(res(:,1)))]';
    
    res_i=interp1(res(:,1),res(:,2),Ei);

    Energy1=50*A;
    Energy2=100*A;
    [index2,value]=find(Ei(:,1)==Energy1);
    [index3,value]=find(Ei(:,1)==Energy2);
    
    resan(index1,1)=x;
    resan(index1,2)=res_i(index2,1);
    resan(index1,3)=res_i(index3,1);
end

figure
plot(resan(:,1),resan(:,2))
hold on
plot(resan(:,1),resan(:,3))
hold off

save('res.txt','resan','-ascii')
