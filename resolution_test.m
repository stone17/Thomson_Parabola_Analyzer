e=1.60E-19;     %[C] electron charge
mp=1.67E-27;     %[kg] nucleon mass (proton mass)

m=12*mp;         %mass of ion
q=6*e;          %ion charge

B=0.55;                         %B-Field [T]
E=9*1E3/0.02;                  %E-Field [V/m] 
lE=0.1;                        %length of electrodes [m]
lB=0.1;                         %length of magnets [m]
l=0.1000;                                   
D=0.4600;                        %drift [m]

s=4.4400e-004;
figure
Ek=1:1000;
x=(q*B*l*D)./sqrt(2*m.*Ek.*e.*1e6);
y=2.*x.^3.*s./(x.^2-(s./2).^2).^2;

plot(Ek,y)
