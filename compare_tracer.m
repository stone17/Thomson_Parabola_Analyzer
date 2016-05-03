function [diff]=compare_tracer(E,lE,B,lB,D,a,A)

% E     [V/m] electric field strength
% lE    [m] electric field length
% B     [T] magnetic field strength
% lB    [m] magnetic fielt length
% D     [m] drift after "B-field"
% a     [] charge of ion in numbers of e-
% A     [] mass of ions in numbers of proton mass

[trace_rela]=tracer_rk(E,lE,B,lB,D,a,A);

[trace_classic]=tracer(E,lE,B,lB,D,a,A);

xi=round(min(trace_classic(:,2))*100)/100:1e-2:round(max(trace_classic(:,2))*100)/100;
xi=xi';

Ei_rela=interp1(trace_rela(:,2),trace_rela(:,1),xi);
Ei_classic=interp1(trace_classic(:,2),trace_classic(:,1),xi);

diff(:,1)=xi;
diff(:,2)=Ei_rela-Ei_classic;
diff(:,3)=Ei_rela;
diff(:,4)=Ei_classic;
end