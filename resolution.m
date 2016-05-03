function [reso]=resolution(E,lE,B,lB,D,a,A,spot,method)

if nargin==8 || strcmp(method,'classic')
    trace=tracer(E,lE,B,lB,D,a,A);  %load trace for specific ion
elseif strcmp(method,'relativistic')
    trace=tracer_rk(E,lE,B,lB,D,a,A);  %load trace for specific ion
elseif strcmp(method,'rk')
    trace=tracer_rk(E,lE,B,lB,D,a,A);  %load trace for specific ion
else
    disp('Unknown method')
    trace=tracer(E,lE,B,lB,D,a,A);  %load trace for specific ion
end
llim=min(trace(:,2));           %lower limit for interpolation
ulim=max(trace(:,2));           %upper limit for interpolation

iy=llim:spot/2:ulim;            %interpolation in steps of diameter/2
iE = interp1(trace(:,2),trace(:,1),iy);

highiE=iE(1:length(iE)-2);     %calculation of DeltaE
lowiE=iE(3:length(iE));

deltaE=(highiE-lowiE)';
iE=iE(2:length(iE)-1)';

highiE=highiE';
lowiE=lowiE';

reso(:,1)=iE/1E6;
reso(:,2)=deltaE./iE;                 %Resolution
reso(:,3)=(iE-lowiE)*1e-6;                    %lower Resolution
reso(:,4)=(highiE-iE)*1e-6;                   %upper Resolution

end