function [spectrum]=spectr(helloworld)
%function [spectrum]=spectr(xtrace,incx,ytrace,incy,Energy,diam,width,Matrix)
global Energy
load dataspec
if exist('yiback','var')
    yi=yiback;
end
incx;
incy;
imlength=size(Matrix);

nansx=find(isnan(xi));   %get number of NAN entries
nansy=find(isnan(yi));
nansE=find(isnan(Ei));
nans(1,1)=length(nansx);
nans(1,2)=length(nansy);
nans(1,3)=length(nansE);

nan=max(nans);

%remove NAN entries
xtrace=xi((nan)+1:length(xi));
ytrace=yi((nan)+1:length(yi));
Energy=Ei((nan)+1:length(Ei));

%cut simulated spectrum
Diff=sqrt((Energy-cut*1e6).^2);
[value,index]=min(Diff);
xtrace=xtrace(index:length(xtrace));
ytrace=ytrace(index:length(ytrace));
Energy=Energy(index:length(Energy));

xspec=round(xtrace/(incx*1E-3));
yspec=round(ytrace/(incy*1E-3));

%Convert spot size to pixel
bin_old=round(spot/(incx*1E-3));
bin;
if bin <2;
    bin=2;
end
%Convert line width to pixel
width=round(width/(incy*1E-3));
if width<2
    width=2;
end

%calulate limit of binning
xlimimage=imlength(1,2); %limit of image in x-dimension
xlimplot=max(xspec);  %x-limit of simulated plot

ylimimage=imlength(1,1); %limit of image in y-dimension
ylimplot=max(yspec); %y-limit of simulated plot

if xlimimage<xlimplot %x image is shorter than x-plot
    if ylimimage<ylimplot
        lim=xlimimage;
    end
    lim=xlimimage;
else
    lim=xlimplot;
end

if checktr==1
figure(1);
imagesc(Matrix)
caxis([cmin cmax])
axis xy
end

indey=0;
index=0;
total=0;

for a=xspec(1,1):bin:lim-bin
    index=index+1;
    value=0;
    for b=a:1:a+bin-1;
        count=0;
        indey=indey+1;
        if indey<=length(yspec) 
        for c=yspec(1,indey)-round(width/2):1:yspec(1,indey)-round(width/2)+width-1
        %for c=yspec(1,indey)-round(width/2):1:yspec(1,indey)+round(width/2) counts to much pixel in y dimension
            if c>0 && c<imlength(1,1)
                if checktr==1
                    hold on
                    plot (b,c,'o','color','g')
                    pause(0.0001)
                    hold off
                end
                count=count+1;
                value=value+(Matrix(c,b));
                total=total+(Matrix(c,b));
            end
        end
        end
    end
    if checktr==1
        hold on
        plot (b,c,'o','color','r')
        pause(0.0001)
        hold off
	end
    if indey+bin<=length(Energy) && indey-round(bin/2)>0        
    MEV=(Energy(indey)-Energy(indey+bin))/1E6;  %add 1 to have correct energy window! now its invariant to changes of binning size.
    if ~isnan(MEV)
    %spectrum(index,1)=Energy(indey-round(bin/2))/1E6;
        spectrum(index,1)=Energy(indey)/1E6-MEV/2;
        spectrum(index,2)=value/MEV; %counts per MeV
        spectrum(index,3)=value; %counts per bin
        spectrum(index,4)=MEV;   %delta E of bin
        spectrum(index,5)=1/MEV;
    end
    end
end
end