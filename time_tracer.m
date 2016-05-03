function [trace]=time_tracer(E,lE,B,lB,D,a,A,Ekin,vx0,vy0,vz0,x0,y0,z0)

% E     [V/m] electric field strength
% lE    [m] electric field length
% B     [T] magnetic field strength
% lB    [m] magnetic fielt length
% D     [m] drift after "B-field"
% a     [] charge of ion in numbers of e-
% A     [] mass of ions in numbers of proton mass
%Ekin   [eV] Kinetic energy

e=1.60E-19;                                 %[C] electron charge
m=1.67E-27;                                 %[kg] nucleon mass (proton mass)
    
%Ekin=Ekin*1E6; %Kinetic energy (eV)
mp=A*m;         %mass of ion
q=a*e;          %ion charge
w=q/mp*B;       

vz=vz0;
tE_est=lE/vz; %approximate time in E-field 
tB_est=lB/vz; %approximate time in B-field

t=0.01*tB_est:0.01*tB_est:1.9*tB_est;           %calculate t versus z for 1% to 190% of estimated t in B-field
z=vz./w.*sin(w.*t)+vy0./w.*(cos(w.*t)-1)+z0;

[aB,bB]=max(z);                                 %check if ion is escaping B-field (max z > lentgh B ?)
if aB>lB
    zB=z(1:bB);
    t=t(1:bB);
    status=0;
    ziB=round(min(z)*100)/100:0.01:aB;
    tiB = interp1(zB,t,ziB); 
    tfield_real=tiB(find(round(ziB*100)/100==round(lB*100)/100)); %extrapolate real time in B-field
else
    status=1;
end

t=0.01*tE_est:0.01*tE_est:1.9*tE_est;           %check if ion is escaping E-field (max z > lentgh E ?)
z=vz./w.*sin(w.*t)+vy0./w.*(cos(w.*t)-1)+z0;


[aE,bE]=max(z);
if aE>lE && status==0
    zE=z(1:bE);
    t=t(1:bE);
    status=0;
    ziE=round(min(z)*100)/100:0.01:aE;
    tiE = interp1(zE,t,ziE); 
    tfield_realE=tiE(find(round(ziE*100)/100==round(lE*100)/100));  %extrapolate real time in B-field
else
    status=1;
end


if status==0        %continue if ion is escaping E-field and B-field

vz_real=vz*cos(w*tfield_real)+vy0*sin(w*tfield_real);           %z-velocity after B-field
vx=q/mp*E*tfield_realE+vx0;                                     %x-velocity of proton due to E-field
vy_real=vz*sin(q/mp*B*tfield_real)+vy0*cos(q/mp*B*tfield_real); %y-velocity of proton due to B-field

xfield=1/2*q/mp*E*tfield_realE^2+vx0*tfield_realE+x0;   %x-displacement due to E-field and time spent in E-field (t=tfield_realE)

%y-displacement due to B-field and time spent in B-field (t=tfield_real)
yfield_real=vz*mp/(B*q)*(1-cos(q/mp*B*tfield_real))+vy0*mp/(B*q)*(sin(q/mp*B*tfield_real))+y0;

tdrift_real=D/vz_real;                    %calculate drift time after B-field
tdrift_realE=(D+lB-lE)/vz_real;           %calculate drift time after E-field

xdrift_real=vx*tdrift_realE;        %x-displacement due to drift after electrodes
ydrift_real=vy_real*tdrift_real;    %y-displacement due to drift after magnets

x_real=xfield+xdrift_real;          %total x-displacement
y_real=yfield_real+ydrift_real;     %total y-displacement

trace(1,1)=Ekin;
trace(1,2)=y_real*1E3;       %B-Field deflection
trace(1,3)=x_real*1E3;       %E-Field deflection
%trace(1,4)=tfield_real+tdrift_real;
%trace(1,5)=yfield_real;
%trace(1,6)=xfield*1E3;
%trace(1,7)=vy_real;
%trace(1,8)=vz_real;
else
trace(1,1)=Ekin;
trace(1,2)=0;       %B-Field deflection
trace(1,3)=0;       %E-Field deflection 
end
end