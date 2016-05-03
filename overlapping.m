function [overlap]=overlapping(B,E,lE,lB,D,diam,method)

%{
B=0.71;                         %B-Field [T]
E=14.4*1E3/0.016;                  %E-Field [V/m] 
lE=0.1;                         %length of electrodes [m]
lB=0.1;                         %length of magnets [m]                                  
D=.356;                        %drift [m]
%}

%ph=0.3;                         %pinhole diameter [mm]
%tph=1250;                       %distance target pinhole [mm]
%phmagnet=50;                     %distance ph magnet [mm]
%diam=ph*(tph+phmagnet+l*1E3+D*1E3)/tph      %spot size on CR39 due to pinhole and divergence [mm]
%diam=0.422;
%e=1.60E-19;                                 %[C] electron charge
%m=12*1.67E-27;                              %[kg] carbon nucleon mass (12*proton mass)

%A=12;

ix=.01:0.01:100;
TRACE(:,1)=ix;

for a=[1,5:6]

    clear trace
    if a==1
        A=1;
    else
        A=12;
    end
    
    if nargin==6 || strcmp(method,'classic')
        trace=tracer(E,lE,B,lB,D,a,A);
    elseif strcmp(method,'relativistic')
        trace=tracer_rk(E,lE,B,lB,D,a,A);
    else
        disp('Unknown method, using classic solver!')
        trace=tracer(E,lE,B,lB,D,a,A);
    end
    
    iy=interp1(trace(:,2),trace(:,3),ix);
    iE=interp1(trace(:,2),trace(:,1),ix);
    
    if a==1
        TRACE(:,2)=iy+diam/2; %upper limit of proton trace
        TRACE(:,3)=iE;
    end
    if a==5
        TRACE(:,4)=iy-diam/2; %lower limit of C5+ trace
        TRACE(:,8)=iE;
    end
    if a==6
        TRACE(:,5)=iy+diam/2; %upper limit of C6+ trace
        TRACE(:,6)=iy-diam/2; %lower limit of C6+ trace
        TRACE(:,7)=iE;
    end
end

distance(:,1)=ix;
distance(:,2)=sqrt((TRACE(:,4)-TRACE(:,5)).^2); %C5+ and C6+
[value,index1]=min(distance(:,2));
overlap(1,1)=distance(index1,1);  %distance of intersection point C5+ and C6+ to zero point
overlap(2,1)=TRACE(index1,7)/1E6; %energy of C6+ in MeV at intersection point C5+ and C6+ 
overlap(6,1)=TRACE(index1,8)/1E6; %energy of C5+ in MeV at intersection point C5+ and C6+ 

distance(:,3)=sqrt((TRACE(:,2)-TRACE(:,6)).^2); %C6+ and proton
[value,index2]=min(distance(:,3));
overlap(3,1)=distance(index2,1);  %distance of intersection point C6+ and proton to zero point
overlap(4,1)=TRACE(index2,7)/1E6; %energy of C6+ in MeV at intersection point C6+ and proton 
overlap(5,1)=TRACE(index2,3)/1E6; %energy of proton in MeV at intersection point C6+ and proton

%overlap
end