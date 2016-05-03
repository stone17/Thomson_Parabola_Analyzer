function [trace]=tracer(E,lE,B,lB,D,a,A)

% E     [V/m] electric field strength
% lE    [m] electric field length
% B     [T] magnetic field strength
% lB    [m] magnetic fielt length
% D     [m] drift after "B-field"
% a     [] charge of ion in numbers of e-
% A     [] mass of ions in numbers of proton mass

e=1.60E-19;     %[C] electron charge
m=1.67E-27;     %[kg] nucleon mass (proton mass)

step=0;

if round(A)<2.5
	Ek=[0.1E6:0.1E6:0.9E6,1E6:.5E6:9.5E6,10E6:1E6:49E6,50E6:10E6:200E6];
else
	Ek=[1E6:.5E6:9.5E6,10E6:1E6:49E6,50E6:10E6:190E6,200E6:10E6:1000E6];
end

%Ek=[0.1E6:0.2E6:0.8E6,1E6:.5E6:9.5E6,10E6:1E6:99E6,100E6:5E6:495E6,...
%    500E6:10E6:990E6,1000E6:50E6:2000E6];


for Ek=Ek
%for Ek=[30E6:1E6:49E6,50E6:10E6:550E6]
%for Ek=[5E8]
        
Ekin=Ek;      %Kinetic energy (eV)

mp=A*m;         %mass of ion
q=a*e;          %ion charge
w=q/mp*B;       

%initial proton velocity (m/s)
v=sqrt(2*Ekin*e/mp);   
vz=v;                  %z axis is propagation
vy0=0;                 

%initial proton coordinates
y0=0;
z0=0;

tE_est=lE/vz; %approximate time in E-field 
tB_est=lB/vz; %approximate time in B-field

t=0.01*tB_est:0.01*tB_est:2.9*tB_est;           %calculate t versus z for 1% to 190% of estimated t in B-field
z=vz./w.*sin(w.*t)+vy0./w.*(cos(w.*t)-1)+z0;

[aB,bB]=max(z);                                 %check if ion is escaping B-field (max z > lentgh B ?)
if aB>lB
    zB=z(1:bB);
    t=t(1:bB);
    status=0;
    ziB=round(min(z)*1000)/1000:0.001:aB;
    tiB = interp1(zB,t,ziB); 
    tfield_real=tiB(find(round(ziB*1000)/1000==round(lB*1000)/1000)); %extrapolate real time in B-field
    tfield_real=tfield_real(1,1);
else
    status=1;
end

t=0.01*tE_est:0.01*tE_est:1.9*tE_est;           %check if ion is escaping E-field (xfield > gap of electrodes ?)
z=vz./w.*sin(w.*t)+vy0./w.*(cos(w.*t)-1)+z0;


[aE,bE]=max(z);
if aE>lE && status==0
    zE=z(1:bE);
    t=t(1:bE);
    status=0;
    ziE=round(min(z)*1000)/1000:0.001:aE;
    tiE = interp1(zE,t,ziE); 
    tfield_realE=tiE(find(round(ziE*1000)/1000==round(lE*1000)/1000)); %extrapolate real time in B-field
    
    if isempty(tfield_realE)
        status=1;
    else
        xfield=1/2*q/mp*E*tfield_realE^2;
        if xfield>=0.02
            status=1;
        end
    end
else
    status=1;
end

if status==0        %continue if ion is escaping E-field and B-field
    
step=step+1;
vz_real=vz*cos(w*tfield_real)+vy0*sin(w*tfield_real);   %calculate z-velocity after B-field

tdrift_real=D/vz_real;                    %calculate drift time after B-field
tdrift_realE=(D+lB-lE)/vz_real;           %calculate drift time after E-field

vx=q/mp*E*tfield_realE;                   %x-velocity of proton due to E-field

vy_real=vz*sin(q/mp*B*tfield_real)+vy0*cos(q/mp*B*tfield_real); %y-velocity of proton due to B-field


xfield=1/2*q/mp*E*tfield_realE^2;     %x-displacement due to E-field and time spent in E-field (t=tfield_realE)

%y-displacement due to B-field and time spent in B-field (t=tfield_real)
yfield_real=vz*mp/(B*q)*(1-cos(q/mp*B*tfield_real))+vy0*mp/(B*q)*(sin(q/mp*B*tfield_real))+y0;

xdrift_real=vx*tdrift_realE;        %x-displacement due to drift after electrodes
ydrift_real=vy_real*tdrift_real;    %y-displacement due to drift after magnets

x_real=xfield+xdrift_real;          %total x-displacement
y_real=yfield_real+ydrift_real;     %total y-displacement

trace(step,1)=Ekin;
%trace(step,5)=tfield_real+tdrift_real;
%trace(step,3)=yfield_real;
trace(step,4)=xfield*1E3;       %x deflection after E-Field in mm
trace(step,3)=x_real*1E3;       %E-Field deflection in mm
trace(step,2)=y_real*1E3;       %B-Field deflection in mm
%trace(step,7)=vy_real;
%trace(step,8)=vz_real;
end
end
end