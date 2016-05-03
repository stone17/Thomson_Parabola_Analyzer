function [Matrix,incx,incy,fname,pname,data]=loadasf(pname,fname)
clc
if nargin==1
    [fname,pname]=uigetfile({'*.asf;*.pit;*.asc;*.dif;*.tif;*.jpg;*.tiff;*.dat;*.mat;*.img',...
    'Supported Image files'},...
    'Select image file',pname);
elseif nargin==0;
    [fname,pname]=uigetfile({'*.asf;*.pit;*.asc;*.dif;*.tif;*.jpg;*.tiff;*.dat;*.mat;*.img',...
    'Supported Image files'},...
    'Select image file','D:\ZZ_LMU_MPQ\LANL Sep-2009');
elseif nargin==2
end

if fname==0
    Matrix=0;
    incx=0;
    incy=0;
    fname=0;
    pname='C:\';
    return
end
dateiname=strcat(pname,fname);
type=fname(length(fname)-2:length(fname));
g=0; %data can be used with jörg routine
if strcmp(type,'ASF')
    type='asf';
end
if strcmp(type,'DIF')
    type='dif';
end
if strcmp(type,'TIF')
    type='tif';
end
if strcmp(type,'JPG')
    type='jpg';
end

if strcmp(type,'asf')
    
    options.Resize='on';
    options.WindowStyle='normal';
    options.Interpreter='tex';
	prompt = {'Increment in um:'};
	dlg_title = 'Enter binning increment for asf file:';
	num_lines = 1;
	def = {'25','hsv'};
	increment =inputdlg(prompt,dlg_title,num_lines,def,options);
    increment = str2double(cell2mat(increment));

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
   incy = fread(fid,1,'int');
   incx = fread(fid,1,'int');
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
   %data(1-4) x-y coordinates
   %data(5) semi minor axis
   %data(6) eccentricity
   %data(7) density weight?
   %data(8) calculated area?
   %data(9) enclosed area
   %data(10)central brightness?
   
   fclose(fid);
   % calculate coordinates in motorsteps (1um)
   X = jx0 + data(:,1)*incx + data(:,3)/scalex;  %!!!!!!!!!!!!changed - to +
   Y = jy0 + data(:,2)*incy + data(:,4)/scaley;

    if ~isnan(increment)
	pause(0.1)
    incx=increment;
    incy=incx;
    X_spread=max(X)-min(X);
    Y_spread=max(Y)-min(Y);
    X_min=min(X);
    Y_min=min(Y);
    datahist=zeros(round(Y_spread/increment)+1,round(X_spread/increment)+1);
    %datahist(:,:)=1;
        for index=1:length(X)
            %if data(index,9)<400 && data(index,9)>120 && data(index,10)<200
                xvalue=round((X(index)-X_min)/increment)+1;
                yvalue=round((Y(index)-Y_min)/increment)+1;
                datahist(yvalue,xvalue)=datahist(yvalue,xvalue)+1;
            %end
        end
	g=1;
    else
        g=0;
	end
        
   status=1;
elseif strcmp(type,'asc')
    %   skipstr = '%*[^;]%*[^;]%*[^;]%*[^;]%*[^;]%*[^;]%*[^;]';
    %   [X,Z] = textread(FileName,[skipstr '%n%n%*[^\n]'],'delimiter',';','headerlines',1);
    readinstr = '%*[^;]%n%*[^;]%n%*[^;]%n%*[^;]%n%n%*[^\n]';
    [CB,ECC,SMajA,X,Z] = textread(dateiname,readinstr,'delimiter',';','headerlines',1);
    data = [CB ECC SMajA];
    incx=10;
    incy=10;
elseif strcmp (type,'pit')
    fid=fopen(dateiname,'r');
    a=fread(fid,inf,'float32');
    start=14+length(a)-fix(length(a)/14)*14;
    b=a(start+1:length(a));
    %b=a(30:length(a)); % This  works for the new version, Manuel has to send it to me
    c=reshape(b,14,length(b)/14);
    data(:,1)=c(8,:)';              %X
    data(:,2)=c(9,:)';              %Z
    fclose(fid);  %added by bmh
    
    options.Resize='on';
    options.WindowStyle='normal';
    options.Interpreter='tex';
	prompt = {'Increment in um:'};
	dlg_title = 'Enter binning increment for pit file:';
	num_lines = 1;
	def = {'50','hsv'};
	increment =inputdlg(prompt,dlg_title,num_lines,def,options);
    increment = str2double(cell2mat(increment));
	pause(0.1)
    if ~isnan(increment)
    incx=increment;
    incy=incx;
    X_spread=max(data(:,1))-min(data(:,1));
    Y_spread=max(data(:,2))-min(data(:,2));
    X_min=min(data(:,1));
    Y_min=min(data(:,2));
    datahist=zeros(round(Y_spread/increment)+1,round(X_spread/increment)+1);    
    %datahist(:,:)=1;
    for index=1:length(data(:,1))
        xvalue=round((data(index,1)-X_min)/increment)+1;
        yvalue=round((data(index,2)-Y_min)/increment)+1;
       
        datahist(yvalue,xvalue)=datahist(yvalue,xvalue)+1;
    end

    g=1;
    else
    g=0;
    incx=100;
    incy=100;
    end
    
elseif strcmp (type,'pit_') %old
    fid=fopen(dateiname,'r');
    a=fread(fid,inf,'float32');
    b=a(26:length(a));
    c=reshape(b,12,length(b)/12);
    data(:,1)=c(8,:)'; % in micron X
    data(:,2)=c(9,:)';              %Z
    fclose(fid);  %added by bmh
    incx=100;
    incy=100;
elseif strcmp (type,'dat') %ascci file
    datahist=load(dateiname);
    incx=78;
    incy=78;
    g=1;
elseif strcmp (type,'dif') %MBI MCP datafile
    fid = fopen(dateiname,'r');
    datahist = fread(fid,[768 512],'uint16');
    incx=77.47; %micron per pixel
    incy=77.47;
    g=1;
elseif strcmp (type,'iff') %tif
    datahist=double(imread(dateiname,'tiff'));
    %datahist=1*(2^16-datahist);
    incx=25;
    incy=25;
    g=1;
elseif strcmp (type,'mat') %mat
    options.Resize='on';
    options.WindowStyle='normal';
    options.Interpreter='tex';
	prompt = {'X increment in um:','Y increment in um:'};
	dlg_title = 'Enter pixelsiye for mat file:';
	num_lines = 1;
	def = {'50','50'};
	increment =inputdlg(prompt,dlg_title,num_lines,def,options);
    incx = str2double(cell2mat(increment(1,1)));
    incy = str2double(cell2mat(increment(2,1)));
	pause(0.1)
    if ~isnan(incx)
        g=1;
    else
        Matrix=0;
        incx=0;
        incy=0;
        fname=0;
        return
    end
    datahist=cell2mat(struct2cell(load(dateiname)));
    elseif strcmp (type,'tif') %tif
    datahist=double(imread(dateiname,'tiff'));
    %datahist=1*(2^16-datahist);
    incx=25;%25;%195.3125;
    incy=25;%25;%195.3125;
    g=1;
    elseif strcmp (type,'jpg') %jpg
    datahist=(imread(dateiname,'jpeg'));
    datahist=double(datahist(:,:,2));
    %datahist=1*(2^16-datahist);
    incx=22.41;%195.3125;
    incy=22.41;%195.3125;
    g=1;
    elseif strcmp (type,'img') %img
    [p,name,ext] = fileparts(fname);
    inffile=[pname name '.inf'];
        if ~exist(inffile,'file')
            error('MATLAB:imgread:inputParsing', '%s', 'No inf-file found'); 
            Matrix=0;
            incx=0;
            incy=0;
            fname=0;
            return
        else
            fid=textread(inffile,'%s');
            incx=str2double(fid(3));
            incy=str2double(fid(4));
            depth=str2double(fid(5));
            m = str2double(fid(6));
            n = str2double(fid(7));
            S = str2double(fid(8));
            L = str2double(fid(9));
            
        end
    fid=fopen(dateiname,'r');
    datahist = fread(fid, [m,n],'2*uint16','ieee-be')';
    fclose(fid);
    datahist=(incx./100).^2.*4000./S.*10.^(L.*(datahist./2^(depth)-0.5));
    g=1;
else
    Matrix=0;
    incx=0;
    incy=0;
    fname=0;
    return
end

if g==1 %skips binning
    else   %binning for asf and pit files

        if strcmp (type,'pit')
            stepwidthx = 100;
            stepwidthy = 100;
        else
            stepwidthx = 1;
            stepwidthy = 1;
        end

        x = (min(data(:,1)) : stepwidthx : max(data(:,1)));
        y = (min(data(:,2)) : stepwidthy : max(data(:,2)));

        x_bins=length(x);
        y_bins=length(y);

        x_data = data(:,1);
        y_data = data(:,2);

x_spread = max(x_data) - min(x_data);
y_spread = max(y_data) - min(y_data);

if x_spread == 0 | y_spread == 0
  errordlg('Data has zero range', 'Data error', 'modal');
  x_step = [0 0 0];
  y_step = [0 0 0];
  D = zeros(3);
  return;  
end
x_data = ((x_bins - 1)/x_spread)*x_data;
y_data = ((y_bins - 1)/y_spread)*y_data;
x_data = round(x_data - min(x_data)+1);
y_data = round(y_data - min(y_data)+1);
x_data = x_data(~isnan(x_data));
y_data = y_data(~isnan(y_data));

%for iv=1:y_bins/2
%    y_data(iv)=y_data(y_bins+1-iv);
%end


datahist = zeros(y_bins, x_bins);
I = sub2ind([y_bins, x_bins], y_data, x_data);
for c = 1:length(I)
    datahist(I(c)) = datahist(I(c)) + 1;
end

%x_step = min(data(:,1)): x_spread/(x_bins-1) :max(data(:,1));
%xhist= min(data(:,1)): x_spread/(x_bins-1) :max(data(:,1));
%y_step = min(data(:,2)): y_spread/(y_bins-1) :max(data(:,2));
%yhist= min(data(:,2)): y_spread/(y_bins-1) :max(data(:,2));
%end of histogramm_2d

I = find( datahist > 0);
mini = min(min(datahist(I)));    % minimum but > 0, all data are > 0 now
%maxi = max(datahist(:));

datahist( find( datahist<mini ) ) = mini;
%datahist( find( datahist>maxi ) ) = maxi;
end

Matrix=datahist;
