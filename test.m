
close all
clc
clear all

H=load('H.txt');
%C4=load('C4.txt');
%C5=load('C5.txt');
C6=load('C6.txt');

axes('box','on','fontsize',15,'linewidth',1.5)

hold on
for a=1:length(H)
    y=-0.422/2:0.422/10:0.422/2;
    if ~isnan(H(a,1))
        if H(a,1)<100e6
            plot(H(a,2)+y*0,H(a,3)+y,'linewidth',5,'color','g')
        elseif H(a,1)>100e6 && H(a,1)<1000e6
            plot(H(a,2)+y*0,H(a,3)+y,'linewidth',5,'color','y')
        elseif H(a,1)>1000e6 
            plot(H(a,2)+y*0,H(a,3)+y,'linewidth',5,'color','r')
        end
    end
end
%{
for a=1:length(C4)
    y=-0.422/2:0.422/10:0.422/2;
    if ~isnan(C4(a,1))
        if C4(a,1)<100e6
            plot(C4(a,2)+y*0,C4(a,3)+y,'linewidth',5,'color','g')
        elseif C4(a,1)>100e6 && C4(a,1)<1000e6
            plot(C4(a,2)+y*0,C4(a,3)+y,'linewidth',5,'color','y')
        elseif C4(a,1)>1000e6 
            plot(C4(a,2)+y*0,C4(a,3)+y,'linewidth',5,'color','r')
        end
    end
end

for a=1:length(C5)
    y=-0.422/2:0.422/10:0.422/2;
    if ~isnan(C5(a,1))
        if C5(a,1)<100e6
            plot(C5(a,2)+y*0,C5(a,3)+y,'linewidth',5,'color','g')
        elseif C5(a,1)>100e6 && C5(a,1)<1000e6
            plot(C5(a,2)+y*0,C5(a,3)+y,'linewidth',5,'color','y')
        elseif C5(a,1)>1000e6 
            plot(C5(a,2)+y*0,C5(a,3)+y,'linewidth',5,'color','r')
        end
    end
end
%}
for a=1:length(C6)
    y=-0.422/2:0.422/10:0.422/2;
    if ~isnan(C6(a,1))
        if C6(a,1)<100e6
            plot(C6(a,2)+y*0,C6(a,3)+y,'linewidth',5,'color','g')
        elseif C6(a,1)>100e6 && C6(a,1)<1000e6
            plot(C6(a,2)+y*0,C6(a,3)+y,'linewidth',5,'color','y')
        elseif C6(a,1)>1000e6 
            plot(C6(a,2)+y*0,C6(a,3)+y,'linewidth',5,'color','r')
        end
    end
end


plot(H(:,2),H(:,3)+0.422/2,'color',[0 0 0]);
plot(H(:,2),H(:,3)-0.422/2,'color',[0 0 0])

%plot(C4(:,2),C4(:,3)+0.422/2,'color',[0 0 0])
%plot(C4(:,2),C4(:,3)-0.422/2,'color',[0 0 0])

%plot(C5(:,2),C5(:,3)+0.422/2,'color',[0 0 0])
%plot(C5(:,2),C5(:,3)-0.422/2,'color',[0 0 0])

plot(C6(:,2),C6(:,3)+0.422/2,'color',[0 0 0])
plot(C6(:,2),C6(:,3)-0.422/2,'color',[0 0 0])

xlabel('Magnetic - Defelction (mm)','fontsize',18);
ylabel('Electric - Defelction (mm)','fontsize',18);
axis([0 200 0 20])
hold off

%create arrows
annotation(gcf,'arrow',[0.24 0.23],...
    [0.42 0.19],'HeadStyle','cback2','LineWidth',3); %C6+ arrow

annotation(gcf,'arrow',[0.676 0.402],... 
    [0.185 0.183],'HeadStyle','cback2','LineWidth',3); %H+ arrow

text('String',['C^{6+} - cutoff at',sprintf('\n'),'420MeV/nucleon'],...
    'Position',[9.73036342321219 8.98412698412699 17.3205080756888],...
    'FontSize',17);
text(160,15,'C^{6+}','fontsize',17)
text(145,1.5,'H^{+} - cutoff at 500MeV','fontsize',17)
text(160,8.5,'H^{+}','fontsize',17)

%create lines
annotation(gcf,'arrow',[0.55 0.55],...
    [0.7865 0.2675],'HeadStyle','cback2','LineWidth',3);
annotation(gcf,'arrow',[0.364 0.364],...
    [0.7875 0.2175],'HeadStyle','cback2','LineWidth',3);
text('String','>1GeV',...
    'Position',[40.4454865181712 15.7142857142857 17.3205080756888],...
    'FontSize',17);


set(gcf,'position',[100 300 1100 400]);