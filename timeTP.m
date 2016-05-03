clear all
close all
clc

E=40e3/0.02;    %electric field strength of TP
lE=0.2;         %elctrode length of TP
B=0.91;         %magentic fied strength of TP
lB=0.2;         %magnet length of TP
D=0.5;            %drift of TP
a=6;            %charge
A=12;            %mass number

f=1/(4*1e-10);         %frequency of streaking electric field
w=2*pi*f;
Es=30e3/0.01;  %strength of streaking electric field 
lEs=0.2;%0.005;       %length of streaking electric field
dist=0.01;%1.2;       %distance between target and streaking field

e=1.60E-19;     %[C] electron charge
mp=1.67E-27;     %[kg] nucleon mass (proton mass)

m=A*mp;
q=a*e;

delta=0;
for dt=0:0;%250e-12:500e-12
    delta=delta+1;
    step=0;
for Ek=[30E6:.1E6:500E6]
    %for Ek=10e6;
    dt=sqrt((-500/490*(Ek*1e-6)+500*500/490-500)^2);
    dt=4*dt*1e-15;
    dt=0;
    Ekin=Ek;
    vz0=sqrt(2*Ekin*e/m);
    t0=0;%dist/vz0+dt
    t=lEs/vz0; %approximate time in E-field
    %E=cos(w*t)
    %x0=-q*Es/(m*w*w)*(cos(w*t)-cos(w*t0));
    %vx0=+q*Es/(m*w)*(sin(w*t)-sin(w*t0));
    
    %E=n*v/(cm*s)*t-b*kV
    n=-30e3/1e-8;
    b=30e3;
    E=n*t+b
    x0=q/m*(n/6*t^3-n*4*t0^2+b/2*t^2-b*t0*t-n/12*t0^3+b/2*t0^2);
    vx0=q/m*(n/2*(t^2-t0^2)+b*(t-t0));
    
    vy0=0; 
    y0=0;
    z0=0;
    
    ttrace=time_tracer(E,lE,B,lB,D,a,A,Ekin,vx0,vy0,vz0,x0,y0,z0);
    if ttrace(1,2)==0;
    else
        step=step+1;
        timetrace(step,1+(delta-1)*3:3+(delta-1)*3)=ttrace;
        xvx(step,1)=Ek/1e6;
        xvx(step,2)=(x0);
        xvx(step,3)=(vx0);
        %xvx(step,4)=Es*cos(w*t0);
        xvx(step,4)=n*t+b;
        xvx(step,5)=dt*1e15;
    end
end
end
trace=tracer(E,lE,B,lB,D,a,A);
trace_1=tracer(E,lE,B,lB,D,1,1);
plot(timetrace(:,2),timetrace(:,3),'color','r')
hold on
%plot(timetrace(:,2)-.2,timetrace(:,3)-.2,'color','r')
%plot(timetrace(:,2)+.2,timetrace(:,3)+.2,'color','r')
%plot(timetrace(:,5),timetrace(:,6),'color','g')
%plot(timetrace(:,8),timetrace(:,9)-0.2,'color','b')
plot(trace(:,2),trace(:,3),'color',[0 0 1])
plot(trace_1(:,2),trace_1(:,3),'color',[1 0 0])
plot(trace(:,2),trace(:,3)+0.2,'color',[0 0 0])
plot(trace(:,2),trace(:,3)-0.2,'color',[0 0 0])
hold off
%axis([0 1.1*max(timetrace(:,2)) 1.1*min(timetrace(:,3)) 1.1*max(timetrace(:,3))])
figure
plot(xvx(:,1),xvx(:,2))
figure
plot(xvx(:,1),xvx(:,3))
figure
plot(xvx(:,1),xvx(:,4))
figure
plot(xvx(:,1),xvx(:,5))

