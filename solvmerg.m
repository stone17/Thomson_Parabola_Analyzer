
B=0.91;                         %B-Field [T]
E=40*1E3/0.02;                  %E-Field [V/m] 
lE=0.2;                         %length of electrodes [m]
lB=0.2;                         %length of magnets [m]                           
D=0.0;                        %drift [m]
a=1;                            %charge
A=1;                           %atomic number
ph=0.2;                         %pinhole diameter [mm]
e=1.60E-19;                  %[C] electron charge

%trace=tracer_rk(E,lE,B,lB,D,a,A);


E_P=1/4*e*E*(0.2^2+0.3^2)/e/1e6

E_C=1/4*e*6*E*(0.2^2+0.3^2)/e/1e6
