%function [dv]=tracer_runge(E,lE,B,lB,D,a,A)

% E     [V/m] electric field strength
% lE    [m] electric field length
% B     [T] magnetic field strength
% lB    [m] magnetic fielt length
% D     [m] drift after "B-field"
% a     [] charge of ion in numbers of e-
% A     [] mass of ions in numbers of proton mass
clc
%close all
clear all

c=2.99e8; %speed of light [m/s]
e=1.60E-19;     %[C] electron charge
mp=1.67E-27;     %[kg] nucleon mass (proton mass)

a=1;
A=1;

m=A*mp;
q=a*e;


D=0.5;
lB=0.1;


index1=0;
for Ekin=[10E6:1e6:49e6,50e6:10E6:600E6]
    index1=index1+1;
    Ekin/1e6
    
    vz=sqrt(2*Ekin*e/m);
    vx=0;
    vy=0; 
       
    ttotal=lB/vz;
    tstep=ttotal*1e-2;
    
    Ex=10e3/0.02; 
    Ey=0;
    Ez=0;

    Bx=.5;
    By=0;
    Bz=0;
    
    x0=0;   
    y0=0;
    z0=0;
    
    s(1)=x0;  %x coordinate
    s(2)=y0;  %y coordinate
    s(3)=z0;  %z coordinate
   
    dv(1,1)=vx;
    dv(1,2)=vy; 
    dv(1,3)=vz;  
    dv(1,4)=0; %time
    
    
    index2=1;
    while z0<lB %z0<=lB
        index2=index2+1;
        
        dv(index2,1) = q/m*(Ex+vy*Bz-vz*By);
        dv(index2,2) = q/m*(Ey+vz*Bx-vx*Bz);
        dv(index2,3) = q/m*(Ez+vx*By-vy*Bx);
        
        for dim=1:3            
            %claculate velocities with Runge-Kutta 4th order
            k1 = tstep * dv(index2,dim);
            k2 = tstep*(dv(index2,dim)+k1/2);
            k3 = tstep*(dv(index2,dim)+k2/2);
            k4 = tstep*(dv(index2,dim)+k3);
            
            dv(index2,dim) = dv(index2-1,dim) + k1/6 + k2/3 + k3/3 + k4/6;

            %calculate x,y,z coordinates 
            s(index2,dim)=s(index2-1,dim)+dv(index2,dim)*tstep;
        end
        dv(index2,4)=(index2-1)*tstep;
        z0=s(index2,3);
        %set new start values for next cycle
        vx=dv(index2,1);
        vy=dv(index2,2);
        vz=dv(index2,3);
           
        if z0>=lB %stop at correct z position    
            
            s_min=sqrt((s(:,3)-lB).^2);
            [value,index3]=min(s_min);        
            
            t=dv(:,4);
            ti=min(t):(max(t)-min(t))/100:max(t);
            six=interp1(t,s(:,1),ti);
            siy=interp1(t,s(:,2),ti);
            siz=interp1(t,s(:,3),ti);
            vix=interp1(t,dv(:,1),ti);
            viy=interp1(t,dv(:,2),ti);
            viz=interp1(t,dv(:,3),ti);

            siz_min=sqrt((siz-lB).^2);
            [value,index3]=min(siz_min);
            x=six(index3);
            y=siy(index3);
            z=siz(index3);
            vx=vix(index3);
            vy=viy(index3);
            vz=viz(index3);
            
            %{
            x=s(index3,1);
            y=s(index3,2);
            z=s(index3,3);
            vx=dv(index3,1);
            vy=dv(index3,2);
            vz=dv(index3,3);
            %}
            
            
        end        
    end
    sx=s;
    clear dv s
     
    %calculate drift
    tremain=D/vz;
    trace(index1,1)=Ekin/1e6;
    trace(index1,3)=(x+vx*tremain)*1e3;
    trace(index1,2)=(y+vy*tremain)*1e3;   
end

[trace_old]=tracer(Ex,lB,Bx,lB,D,a,A);

figure
%plot(dv(:,4),s(:,1),'x','color','r')
hold on
%plot(dv(:,4),s(:,2),'o','color','g')
%plot(dv(:,4),s(:,3),'color','b')
plot(trace(:,2),trace(:,3),'color','b')
plot(trace_old(:,2),trace_old(:,3),'color','r')
hold off


%end