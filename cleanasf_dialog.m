function varargout = cleanasf_dialog(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cleanasf_dialog_OpeningFcn, ...
                   'gui_OutputFcn',  @cleanasf_dialog_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before cleanasf_dialog is made visible.
function cleanasf_dialog_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
start_Callback(hObject, eventdata, handles)

% UIWAIT makes cleanasf_dialog wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cleanasf_dialog_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


function start_Callback(hObject, eventdata, handles)
global pname fname 
%if ~ischar(fname) 
    [fname,pname]=uigetfile({'*.asf','Supported Image files'},'Select image file',pname);
%end

if ~ischar(fname) || ~ischar(pname)
    CloseConfiguration_Callback(hObject,eventdata, handles)
    return
end

options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
prompt = {'Increment in um:'};
dlg_title = 'Enter binning increment for asf file:';
num_lines = 1;
def = {'50','hsv'};
increment =inputdlg(prompt,dlg_title,num_lines,def,options);
increment = str2double(cell2mat(increment));

dateiname=strcat(pname,fname);
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
set(handles.semi_min,'string',num2str(min(data(:,5))))
set(handles.semi_max,'string',num2str(max(data(:,5))))
set(handles.ecc_min,'string',num2str(min(data(:,6))))
set(handles.ecc_max,'string',num2str(max(data(:,6))))
set(handles.ea_min,'string',num2str(min(data(:,9))))
set(handles.ea_max,'string',num2str(max(data(:,9))))
set(handles.cb_min,'string',num2str(min(data(:,10))))
set(handles.cb_max,'string',num2str(max(data(:,10))))

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
    Matrix=zeros(round(Y_spread/increment)+1,round(X_spread/increment)+1);
    dataea=zeros(round(Y_spread/increment)+1,round(X_spread/increment)+1);
    datacb=zeros(round(Y_spread/increment)+1,round(X_spread/increment)+1);
    datasemi=zeros(round(Y_spread/increment)+1,round(X_spread/increment)+1);
    dataecc=zeros(round(Y_spread/increment)+1,round(X_spread/increment)+1);
    %Matrix(:,:)=1;
        for index=1:length(X)
            %if data(index,9)<400 && data(index,9)>120 && data(index,10)<200
                xvalue=round((X(index)-X_min)/increment)+1;
                yvalue=round((Y(index)-Y_min)/increment)+1;
                Matrix(yvalue,xvalue)=Matrix(yvalue,xvalue)+1;
                datasemi(yvalue,xvalue)=datasemi(yvalue,xvalue)+data(index,5);
                dataecc(yvalue,xvalue)=dataecc(yvalue,xvalue)+data(index,6);
                dataea(yvalue,xvalue)=dataea(yvalue,xvalue)+data(index,9);
                datacb(yvalue,xvalue)=datacb(yvalue,xvalue)+data(index,10);
            %end
        end
end
dataea=dataea./Matrix;
datacb=datacb./Matrix;
datasemi=datasemi./Matrix;
dataecc=dataecc./Matrix;

axes(handles.clean_plot);
imlength=size(Matrix);
ylength=0:incy*1E-3:imlength(1,1)*incy*1E-3;
xlength=0:incx*1E-3:imlength(1,2)*incx*1E-3;
imagesc(xlength,ylength,Matrix);
axis xy
T=title(fname);
set(T,'Interpreter','none')
cmin=min(min(Matrix));
cmax=max(max(Matrix));
caxis([cmin cmax]);

setappdata(handles.clean_plot,'data',data)
setappdata(handles.clean_plot,'Matrix',Matrix)
setappdata(handles.clean_plot,'dataea',dataea)
setappdata(handles.clean_plot,'datacb',datacb)
setappdata(handles.clean_plot,'datasemi',datasemi)
setappdata(handles.clean_plot,'dataecc',dataecc)
setappdata(handles.clean_plot,'X',X)
setappdata(handles.clean_plot,'Y',Y)
setappdata(handles.clean_plot,'increment',increment)
setappdata(handles.clean_plot,'xlength',xlength)
setappdata(handles.clean_plot,'ylength',ylength)

% --- Executes on button press in enclosed.
function enclosed_Callback(hObject, eventdata, handles)
xlength=getappdata(handles.clean_plot,'xlength');
ylength=getappdata(handles.clean_plot,'ylength');

button=num2str(get(hObject,'Tag'));
if strcmp(button,'enclosed') || strcmp(button,'ea_min') || strcmp(button,'ea_max')
    data=getappdata(handles.clean_plot,'dataea');
elseif strcmp(button,'central') || strcmp(button,'cb_min') || strcmp(button,'cb_max')
    data=getappdata(handles.clean_plot,'datacb');
elseif strcmp(button,'eccentricity') || strcmp(button,'ecc_min') || strcmp(button,'ecc_max')
    data=getappdata(handles.clean_plot,'dataecc');
elseif strcmp(button,'semi') || strcmp(button,'semi_min') || strcmp(button,'semi_max')
    data=getappdata(handles.clean_plot,'datasemi');
elseif strcmp(button,'replot')
    data=getappdata(handles.clean_plot,'Matrix');
end   

xlim_old=xlim;
ylim_old=ylim;
imagesc(xlength,ylength,data);
axis xy
cmin=min(min(data));
cmax=max(max(data));
caxis([cmin cmax]);
axis([xlim_old ylim_old]);
colormap Jet
colorbar

function min_max_Callback(hObject, eventdata, handles)
global pname fname
ea_min=str2double(get(handles.ea_min,'string'));
cb_min=str2double(get(handles.cb_min,'string'));
ecc_min=str2double(get(handles.ecc_min,'string'));
semi_min=str2double(get(handles.semi_min,'string'));
ea_max=str2double(get(handles.ea_max,'string'));
cb_max=str2double(get(handles.cb_max,'string'));
ecc_max=str2double(get(handles.ecc_max,'string'));
semi_max=str2double(get(handles.semi_max,'string'));

data=getappdata(handles.clean_plot,'data');
X=getappdata(handles.clean_plot,'X');
Y=getappdata(handles.clean_plot,'Y');
increment=getappdata(handles.clean_plot,'increment');

X_spread=max(X)-min(X);
Y_spread=max(Y)-min(Y);
X_min=min(X);
Y_min=min(Y);

Matrix=zeros(round(Y_spread/increment)+1,round(X_spread/increment)+1);
dataea=zeros(round(Y_spread/increment)+1,round(X_spread/increment)+1);
datacb=zeros(round(Y_spread/increment)+1,round(X_spread/increment)+1);
datasemi=zeros(round(Y_spread/increment)+1,round(X_spread/increment)+1);
dataecc=zeros(round(Y_spread/increment)+1,round(X_spread/increment)+1);

%Matrix(:,:)=1;
for index=1:length(X)
	if data(index,5) <= semi_max && data(index,5) >= semi_min
        if data(index,6) <= ecc_max && data(index,6) >= ecc_min
            if data(index,9) <= ea_max && data(index,9) >= ea_min
                if data(index,10) <= cb_max && data(index,10) >= cb_min
                    xvalue=round((X(index)-X_min)/increment)+1;
                    yvalue=round((Y(index)-Y_min)/increment)+1;
                    Matrix(yvalue,xvalue)=Matrix(yvalue,xvalue)+1;
                    datasemi(yvalue,xvalue)=datasemi(yvalue,xvalue)+data(index,5);
                    dataecc(yvalue,xvalue)=dataecc(yvalue,xvalue)+data(index,6);
                    dataea(yvalue,xvalue)=dataea(yvalue,xvalue)+data(index,9);
                    datacb(yvalue,xvalue)=datacb(yvalue,xvalue)+data(index,10);
                end
            end
        end
    end
       
end

setappdata(handles.clean_plot,'Matrix',Matrix)
setappdata(handles.clean_plot,'dataea',dataea./Matrix)
setappdata(handles.clean_plot,'datacb',datacb./Matrix)
setappdata(handles.clean_plot,'datasemi',datasemi./Matrix)
setappdata(handles.clean_plot,'dataecc',dataecc./Matrix)
save([pname, fname,'_cleaned_',num2str(increment), '.mat'],'Matrix')
enclosed_Callback(hObject,eventdata, handles)


% --- Executes during object creation, after setting all properties.
function min_max_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)

function CloseConfiguration_Callback(hObject, eventdata, handles)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
try
rmappdata(handles.clean_plot,'data')
rmappdata(handles.clean_plot,'Matrix')
rmappdata(handles.clean_plot,'dataea')
rmappdata(handles.clean_plot,'datacb')
rmappdata(handles.clean_plot,'datasemi')
rmappdata(handles.clean_plot,'dataecc')
rmappdata(handles.clean_plot,'X')
rmappdata(handles.clean_plot,'Y')
rmappdata(handles.clean_plot,'increment')
rmappdata(handles.clean_plot,'xlength')
rmappdata(handles.clean_plot,'ylength')
end
delete(handles.figure1);
