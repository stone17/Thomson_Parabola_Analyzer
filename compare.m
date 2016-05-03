B=0.55;                         %B-Field [T]
E=16*1E3/0.02;                  %E-Field [V/m] 
lE=0.4;                        %length of electrodes [m]
lB=0.1;                         %length of magnets [m]
l=lB;                                   
D=0.485;                        %drift [m]

ph=0.3;                         %pinhole diameter [mm]
tph=1050;                       %distance target pinhole [mm]
phmagnet=85;                     %distance ph magnet [mm]
diam=ph*(tph+phmagnet+l*1E3+D*1E3)/tph   %spot size on CR39 due to pinhole and divergence [mm]

e=1.60E-19;                     %[C] electron charge
mC=12*1.67E-27;                 %[kg] carbon nucleon mass (12*proton mass)

%a=6;                            %charge
%A=12;                            %atomic number

traceC6=tracer(E,lE,B,lB,D,6,12);
traceO8=tracer(E,lE,B,lB,D,8,16);

plot(traceC6(:,2)/1,traceC6(:,3),'color','r')
hold all
plot(traceO8(:,2)/1,traceO8(:,3),'color','b')
hold on
