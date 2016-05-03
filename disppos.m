function disppos
h.f = figure;
plot(rand(1,10));
grid on;
h.a=gca;
set(h.f,'WindowButtonDownFcn',{@druecken,h});
set(h.f,'WindowButtonUpFcn', {@loesen,h});

function druecken(o,e,h)
pt = get(h.a, 'CurrentPoint');
set(h.f,'Name',num2str([pt(1,1) pt(1,2)]));
set(h.f, 'WindowButtonMotionFcn', {@ziehen,h})
hold on
crosshair=plot(pt(1,1),pt(1,2));
hold off

function ziehen(o,e,h)
pt = get(h.a, 'CurrentPoint');
set(h.f,'Name',num2str([pt(1,1) pt(1,2)]));

function loesen(o,e,h)
set(h.f, 'WindowButtonMotionFcn', '');