function [trace]=tracer_runge(E,lE,B,lB,D,a,A)

% E     [V/m] electric field strength
% lE    [m] electric field length
% B     [T] magnetic field strength
% lB    [m] magnetic fielt length
% D     [m] drift after "B-field"
% a     [] charge of ion in numbers of e-
% A     [] mass of ions in numbers of proton mass

%{
clear all
close all
lB=.2;
lE=.2;
E=20e3/0.02;
B=.5;
D=.5;
a=1;
A=1;
%}

c=2.99e8;       %speed of light [m/s]
e=1.60E-19;     %[C] electron charge
mp=1.67E-27;    %[kg] nucleon mass (proton mass)
m=A*mp;
q=a*e;

if lB<lE %stop lorentz calculation if z>limit
    limit=lE;
    D=D-(lE-lB);
else
    limit=lB;
end
index1=0;

if round(A)<2.5
    Ek=[0.1E6:0.1E6:0.9E6,1E6:.5E6:9.5E6,10E6:1E6:49E6,50E6:10E6:200E6];
else
    Ek=[1E6:.5E6:9.5E6,10E6:1E6:49E6,50E6:10E6:190E6,200E6:10E6:1000E6];
end

for Ekin=Ek
%for Ekin=[10E6:10E6:500E6]
%for Ekin=[1E6:1E6:50E6]
    index1=index1+1;
    Ekin/1e6
    vz=c*sqrt(1-(1/(Ekin*e/(m*c^2)+1))^2);
    vx=0;
    vy=0;

    v=sqrt(vx^2+vy^2+vz^2);
    g=(1-v^2/c^2)^(-1/2);
       
    ttotal=limit/vz;
    tstep=ttotal*1e-3; %accuracy of Runge-Kutta Method
    
    Ex=E; 
    Ey=0;
    Ez=0;

    Bx=B;
    By=0;
    Bz=0;
    
    x0=0;
    y0=0;
    z0=0;
    
    ds(1)=x0;  %x coordinate
    ds(2)=y0;  %y coordinate
    ds(3)=z0;  %z coordinate
   
    dp(1,1)=g*vx/c;
    dp(1,2)=g*vy/c; 
    dp(1,3)=g*vz/c;  
    dp(1,4)=0; %time
    
    error=0; %is set to 1 when particle cannot escape the fields
    index2=1;
    %limit=0.7;
    while z0<=limit %z0<=lB
        index2=index2+1;
        
        
        %Ex=6000/(0.002+sin(2.25/20)*z0);
        if z0>lE
            Ex=0;
        elseif z0>lB
            Bx=0;
        end

        %if z0>0.2 && z0<0.4
        %   Ex=0;
        %else %if z0>=0 && z0<=0.2 || z0>=0.4 && z0<=0.7
        %   Ex=E;
        %   z0
        %end
        %relativistic lorentz equatuions with p=g*v/c
        dp(index2,1) = q/(m*c)*(Ex+vy*Bz-vz*By);
        dp(index2,2) = q/(m*c)*(Ey+vz*Bx-vx*Bz);
        dp(index2,3) = q/(m*c)*(Ez+vx*By-vy*Bx);

        for dim=1:3            
            %claculate momenta with Runge-Kutta 4th order
            k1 = tstep * dp(index2,dim);
            k2 = tstep * (dp(index2,dim)+k1/2);
            k3 = tstep * (dp(index2,dim)+k2/2);
            k4 = tstep * (dp(index2,dim)+k3);
            dp(index2,dim) = dp(index2-1,dim) + k1/6 + k2/3 + k3/3 + k4/6;
        end
        
        p=sqrt(dp(index2,1).^2+dp(index2,2).^2+dp(index2,3).^2); %total p
        g=sqrt(1+p^2); %total gamma
        dp(index2,4)=(index2-1)*tstep; %write down time
         
        %calculate x,y,z coordinates with Runge-Kutta 4th order
        ds(index2,1)=dp(index2,1)*c/g;
        ds(index2,2)=dp(index2,2)*c/g;
        ds(index2,3)=dp(index2,3)*c/g;
        %s(index2,dim)=s(index2-1,dim)+dp(index2,dim)*c/g*tstep;
        for dim=1:3 
            k1 = tstep * ds(index2,dim);
            k2 = tstep * (ds(index2,dim)+k1/2);
            k3 = tstep * (ds(index2,dim)+k2/2);
            k4 = tstep * (ds(index2,dim)+k3);
            ds(index2,dim) = ds(index2-1,dim) + k1/6 + k2/3 + k3/3 + k4/6;
        end
        
        if z0<=ds(index2,3)
            z0=ds(index2,3);
        else %exit loop if particle cannot escape the field
            z0=10*limit;
            error=1;
            index1=index1-1;
        end
            
        %set new start values for next cycle
        vx=dp(index2,1)*c/g;
        vy=dp(index2,2)*c/g;
        vz=dp(index2,3)*c/g;
          
        if z0>=limit && error==0 %stop at correct z position             
            %s_min=sqrt((s(:,3)-lB).^2);
            %[value,index3]=min(s_min); 
            %{
            x=s(index3,1);
            y=s(index3,2);
            z=s(index3,3);
            vx=dv(index3,1);
            vy=dv(index3,2);
            vz=dv(index3,3);
            %}
            t=dp(:,4);
            ti=min(t):(max(t)-min(t))/1000:max(t);
            six=interp1(t,ds(:,1),ti);
            siy=interp1(t,ds(:,2),ti);
            siz=interp1(t,ds(:,3),ti);
            pix=interp1(t,dp(:,1),ti);
            piy=interp1(t,dp(:,2),ti);
            piz=interp1(t,dp(:,3),ti);

            siz_min=sqrt((siz-limit).^2);
            [value,index3]=min(siz_min);
            x=six(index3);
            y=siy(index3);
            z=siz(index3);
            vx=pix(index3)*c/g;
            vy=piy(index3)*c/g;
            vz=piz(index3)*c/g;
        end        
    end
    clear dp ds six siy siz pix piy piz

    if error==0
    %calculate drift
    %tremain=D/vz;
    tremain=0.3/vz;
    trace(index1,1)=Ekin;                   %energy in MeV
	trace(index1,3)=(x+vx*tremain)*1e3;     %x deflection
    trace(index1,2)=(y+vy*tremain)*1e3;     %y deflection
    trace(index1,4)=x*1E3;                  %x after passing fields
    end
end

%[trace_old]=tracer(E,lE,B,lB,D,a,A);
%hold on
%plot(trace(:,2),trace(:,3),'color','b')
%plot(trace_old(:,2),trace_old(:,3),'color','r')
%hold off
%figure
%plot(trace(:,1)/1e6,trace_old(:,3)-trace(:,3),'color','r');
%hold on
%plot(trace(:,1)/1e6,trace_old(:,2)-trace(:,2));
%hold off
end