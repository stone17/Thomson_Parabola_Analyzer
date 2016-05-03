clc
clear all

index=0;

B=0.5;          %B-field in [T]
dist=0.02;      %electrode distance [m]
E=25*1e3/dist;  %E-field in V/m
lB=0.1;         %length of B-field in [m]
D=0.7;          %drift length in [m]
diameter=0.3;   %pinhole diameter in [mm]

tph=1250;       %distance target pinhole [mm]
phmagnet=50;    %distance pinhole magnets [mm]
diam=diameter*(tph+phmagnet+lB*1E3+D*1E3)/tph; %spotsize on detector


for lE=0.05:0.05:0.3;
    index=index+1
 
    %calculate overlap C5+ and C6+
    overlap=overlapping(B,E,lE,lB,D,diam);
    
    Ekill(index,1)=lE;
    Ekill(index,2)=overlap(2,1);
    
    %calculate corresponding traces for proton and C6+
    proton_trace=tracer(E,lE,B,lB,D,1,1);
    carbon_trace=tracer(E,lE,B,lB,D,6,12);
    
    %Calculate cutoff due to electrodes    
    search_p=sqrt((proton_trace(:,4)-dist*1E3).^2);
    [val_p,ind_p]=min(search_p);
   
    Ekill(index,3)=proton_trace(ind_p,1)/1e6; %proton
    
    search_c=sqrt((carbon_trace(:,4)-dist*1E3).^2);
    [val_c,ind_c]=min(search_c);
    
	Ekill(index,4)=carbon_trace(ind_c,1)/1e6; %C6+
    
end

%{
%calculate resolution
index=0;
lE=0.5;
for B=0.5:0.05:1
    index=index+1
    clear pro_Res car_Res
    pro_trace=tracer(E,lE,B,lB,D,1,1);  %load trace for proton
    car_trace=tracer(E,lE,B,lB,D,6,12);  %load trace for proton
    
    pro_llim=min(pro_trace(:,2));           %lower limit for interpolation H+
    pro_ulim=max(pro_trace(:,2));           %upper limit for interpolation H+
    
    car_llim=min(car_trace(:,2));           %lower limit for interpolation C6+
    car_ulim=max(car_trace(:,2));           %upper limit for interpolation C6+
    
    pro_iy=pro_llim:diam/2:pro_ulim;        %interpolation in steps of diameter/2 H+
    pro_iE = interp1(pro_trace(:,2),pro_trace(:,1),pro_iy);
    
    car_iy=car_llim:diam/2:car_ulim;        %interpolation in steps of diameter/2 C6+
    car_iE = interp1(car_trace(:,2),car_trace(:,1),car_iy);
    
    pro_highiE=pro_iE(1:length(pro_iE)-2);  %calculation of DeltaE
    pro_lowiE=pro_iE(3:length(pro_iE));

	car_highiE=car_iE(1:length(car_iE)-2);  %calculation of DeltaE
    car_lowiE=car_iE(3:length(car_iE));

    pro_deltaE=(pro_highiE-pro_lowiE)';     %Resolution H+
    pro_Res(:,1)=pro_iE(2:length(pro_iE)-1)';
    pro_Res(:,2)=pro_deltaE./pro_Res(:,1);
    
    car_deltaE=(car_highiE-car_lowiE)';     %Resolution C6+
    car_Res(:,1)=car_iE(2:length(car_iE)-1)';
    car_Res(:,2)=car_deltaE./car_Res(:,1);
    
    reso(index,1)=B;
    search_p=sqrt((pro_Res(:,1)-500*1e6).^2);
    [val_p,ind_p]=min(search_p);
    reso(index,2)=pro_Res(ind_p,2);
    search_c=sqrt((car_Res(:,1)-500*1e6).^2);
    [val_c,ind_c]=min(search_c);
    reso(index,3)=car_Res(ind_c,2);
end    
%}
figure
plot (Ekill(:,1),Ekill(:,2)) %overlap C5+ C6+
return
figure
hold on
plot (Ekill(:,1),Ekill(:,3)) %cutoff due to electrode distance H+
plot (Ekill(:,1),Ekill(:,4)) %cutoff due to electrode distance C6+
hold off
figure
hold on
plot (reso(:,1),reso(:,2))  %H+
plot (reso(:,1),reso(:,3))  %C6+
hold off
