function [Matrix,incx,incy]=asfmerger(pname)
if nargin==1
    [fname,pname]=uigetfile('*.asf','Select asf files','Multiselect','on',pname);
else
    [fname,pname]=uigetfile('*.asf','Select asf files','Multiselect','on');
end
if iscell(fname)
    l=length(fname);
    error=0;
elseif fname==0
    error=1; %no file selected
else
    error=1; %only one file selected
end

if error==1
    Matrix=0;
    incx=0;
    incy=0;
    return
end

%open dialog box to ask for binning increment of asf file
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
prompt = {'Increment in um:'};
dlg_title = 'Enter binning increment for pit file:';
num_lines = 1;
def = {'50'};
increment =inputdlg(prompt,dlg_title,num_lines,def,options);
increment = str2double(cell2mat(increment));
pause(0.1)
if isnan(increment)
    increment=50;
    incx=increment;
    incy=incx;
else
    incx=increment;
    incy=incx;
end

h = waitbar(0,'Please wait...');
pause(.1)

index=0;
for a=1:l
    string=['Processing file ', num2str(a),' of ', num2str(l)];
    waitbar(a /l,h,sprintf(string))
    pause(.1)
    
    file=cell2mat(fname(1,a));
    dateiname=strcat(pname,file);
    type=dateiname(length(dateiname)-2:length(dateiname));

    if strcmp(type,'ASF')
        type='asf';
    elseif strcmp(type,'asf')
        type='asf'; 
    else
        Matrix=0;
        incx=0;
        incy=0;
        delete(h)
        return%no asf file selected
    end
    fid = fopen(dateiname,'r');

	% header 0
	irec = fread(fid,1,'int');
	scalex = fread(fid,1,'float');
	scaley = fread(fid,1,'float');
	ibright = fread(fid,1,'int');
	icontrast = fread(fid,1,'int');
	junk = fread(fid,4,'int');

	% header 1    
	ipx = fread(fid,1,'int16');
	ipy = fread(fid,1,'int16');
	mx1 = fread(fid,1,'int');
	my1 = fread(fid,1,'int');
	mx2 = fread(fid,1,'int');
	my2 = fread(fid,1,'int');
	incy_asf = fread(fid,1,'int');
	incx_asf = fread(fid,1,'int');
	jx0 = fread(fid,1,'int');
	jy0 = fread(fid,1,'int');
	
	% data read in
	Pos = ftell(fid);       % memorize the position of the file pointer
        
	Col_1to2 = fread(fid,inf,'2*int16',32);   % read in the integers first
	Col_1to2 = reshape(Col_1to2(:),2,length(Col_1to2)/2)';
    
	fseek(fid,Pos+4,-1);      % go back to the position where data start
    
	Col_3to10 = fread(fid,inf,'8*float',4);   % read in the float values
	Col_3to10 = reshape(Col_3to10(:),8,length(Col_3to10)/8)';
    
	data = [Col_1to2 Col_3to10];
   
	fclose(fid);
	% calculate coordinates in motorsteps (1um)
    for b=1:length(data(:,1))
        X(index+b) = jx0 + data(b,1)*incx_asf + data(b,3)/scalex;  %!!!!!!!!!!!!changed - to +
        Y(index+b) = jy0 + data(b,2)*incy_asf + data(b,4)/scaley;
    end
    index=index+b;
end 

delete(h)
       
X_spread=max(X)-min(X);
Y_spread=max(Y)-min(Y);
X_min=min(X);
Y_min=min(Y);
Matrix=zeros(round(Y_spread/incy)+1,round(X_spread/incx)+1);
%datahist(:,:)=1;
        
for index=1:length(X)
	xvalue=round((X(index)-X_min)/incx)+1;
	yvalue=round((Y(index)-Y_min)/incy)+1;
       
	Matrix(yvalue,xvalue)=Matrix(yvalue,xvalue)+1;
end

%save(['asfmerge_',num2str(increment),'um per pixel'],'datahist')
end