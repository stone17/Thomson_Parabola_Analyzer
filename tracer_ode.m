function [trace]=tracer_ode(E,lE,B,lB,D,a,A)

% E     [V/m] electric field strength
% lE    [m] electric field length
% B     [T] magnetic field strength
% lB    [m] magnetic fielt length
% D     [m] drift after "B-field"
% a     [] charge of ion in numbers of e-
% A     [] mass of ions in numbers of proton mass
clc
%close all
%clear all

c=2.99e8; %speed of light [m/s]
e=1.60E-19;     %[C] electron charge
mp=1.67E-27;     %[kg] nucleon mass (proton mass)

a=1;
A=1;

m=A*mp;
q=a*e;


D=0.5;

function dv = lorentz(t,v)
dv = zeros(3,1);    % a column vector
dv(1) = q/m*(Ex+v(2)*Bz-v(3)*By);
dv(2) = q/m*(Ey+v(3)*Bx-v(1)*Bz);
dv(3) = q/m*(Ez+v(1)*By-v(2)*Bx);
end


index1=0;
for Ekin=[10E6:1e6:49e6,50e6:10E6:600E6]
    index1=index1+1;
    Ekin/1e6
    
    vz0=sqrt(2*Ekin*e/m);
    vx0=0;
    vy0=0;
        
    tstep=1e-2/vz0;
    
    Ex=10e3/0.02; 
    Ey=0;
    Ez=0;

    Bx=.5;
    By=0;
    Bz=0;
    
    lB=0.1;
    
    x0=0;   
    y0=0;
    z0=0;
    
   
    index2=0;
    while z0<=lB
        index2=index2+1;
        options = odeset('RelTol',1e-4,'AbsTol',[1e-4 1e-4 1e-5]);
        [t,v] = ode45(@lorentz,[0 tstep],[vx0 vy0 vz0]);%,options);
        for i=1:length(v)-1
            if i==1 %calculate x,y,z coordinates 
                s(1,1)=x0;  %x coordinate
                s(1,2)=y0;  %y coordinate
                s(1,3)=z0;  %z coordinate
            else
                s(i,1)=(v(i,1)+v(i-1,1))/2*(t(i)-t(i-1))+s(i-1,1);
                s(i,2)=(v(i,2)+v(i-1,2))/2*(t(i)-t(i-1))+s(i-1,2);
                s(i,3)=(v(i,3)+v(i-1,3))/2*(t(i)-t(i-1))+s(i-1,3);
            end
        end
        
        %set new start values for next cycle
        x0=s(i,1);
        y0=s(i,2);
        z0=s(i,3);
        vx0=v(i,1);
        vy0=v(i,2);
        vz0=v(i,3);
        
        if z0>=lB %stop at correct z position
            t=t(2:length(t)-1);
            ti=min(t):(max(t)-min(t))/100:max(t);
            six=interp1(t,s(2:length(s),1),ti);
            siy=interp1(t,s(2:length(s),2),ti);
            siz=interp1(t,s(2:length(s),3),ti);
            vix=interp1(t,v(2:length(v)-1,1),ti);
            viy=interp1(t,v(2:length(v)-1,2),ti);
            viz=interp1(t,v(2:length(v)-1,3),ti);

            siz_min=sqrt((siz-lB).^2);
            [value,index3]=min(siz_min);
            x0=six(index3);
            y0=siy(index3);
            z0=siz(index3);
            vx0=vix(index3);
            vy0=viy(index3);
            vz0=viz(index3);
        end
        
        clear s t v
    end
     
    %calculate drift
    tremain=D/vz0;
    trace(index1,1)=Ekin/1e6;
    trace(index1,3)=(x0+vx0*tremain)*1e3;
    trace(index1,2)=(y0+vy0*tremain)*1e3;   
end

[trace_old]=tracer(Ex,lB,Bx,lB,D,a,A);

figure
%plot(trace(:,1),trace(:,2),'x','color','r')
hold on
%plot(trace(:,1),trace(:,3),'o','color','g')
plot(trace(:,2),trace(:,3),'color','b')
plot(trace_old(:,2),trace_old(:,3),'color','r')
hold off


end