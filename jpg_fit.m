clc
x(1,1)=283.44;
x(2,1)=328.06;
x(3,1)=372.67;
x(4,1)=417.29;
x(5,1)=461.90;
plot(x)
y=(1:length(x))';


f = fittype('a*x+b');
[c,gof] = fit(x,y,f)