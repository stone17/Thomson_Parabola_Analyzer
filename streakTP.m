clc
clear all

e=1.60E-19;                                 %[C] electron charge
m=1.67E-27;                                 %[kg] nucleon mass (proton mass)
    
%Ekin=Ekin*1E6; %Kinetic energy (eV)
mp=m;            %mass of proton
mc=12*m;         %mass of carbon
qc=6*e;          %ion charge
qp=e;

  
Emaxc=500*1e6*e;
Eminc=25*1e6*e;

vmaxc=sqrt(2*Emaxc/mc);
vminc=sqrt(2*Eminc/mc);

tmin=1/vmaxc;

tmax=1/vminc;

deltat=tmax-tmin;

gradE=3500/deltat;
gradE_500fs=gradE*1e12*500;

index=0;
for a=[25:99,100:10:500];
    a
    
    v=sqrt(2*a*1e6*e/mc);
    t=1/v;
    Efield_0fs=4000-gradE*(t-tmin);
    Efield_500fs=4000-gradE*(t-tmin+500*1e-12);
    trace_0fs=tracer(Efield_0fs/0.03,0.4,0.57,0.20,0.4,6,12); %retrieve trace for current parameters
    trace_500fs=tracer(Efield_500fs/0.03,0.4,0.57,0.20,0.4,6,12);
    
    index_0fs=find(trace_0fs(:,1)==a*1e6);
    index_500fs=find(trace_500fs(:,1)==a*1e6);
    if isempty(index_0fs)
    else
        index=index+1;
        y_0fs=trace_0fs(index_0fs,3);
        y_500fs=trace_500fs(index_500fs,3);
        delta_y(index,1)=a;
        delta_y(index,2)=y_0fs-y_500fs; %y deviation for to ions of energy 'a' with a distance of 500fs over 1meter
    end
end

plot (delta_y(:,1),delta_y(:,2)*1e3)
