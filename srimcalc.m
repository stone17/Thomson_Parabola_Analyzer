function varargout = srimcalc(varargin)
% Edit the above text to modify the response to help srimcalc

% Last Modified by GUIDE v2.5 26-Jan-2011 15:10:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @srimcalc_OpeningFcn, ...
                   'gui_OutputFcn',  @srimcalc_OutputFcn, ...
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


% --- Executes just before srimcalc is made visible.
function srimcalc_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = srimcalc_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in layer1.
function layers_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function layers_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function thickness_Callback(hObject, eventdata, handles)
tg=get(hObject,'Tag');
thick=str2double(get(hObject,'String'));
if isnan(thick)
    if strcmp(tg,'thickness1')
        thick=10;
    elseif strcmp(tg,'thickness2')
        thick=1000;
    end
elseif thick<0
    thick=-thick;
end
set(hObject,'String',num2str(thick))


% --- Executes during object creation, after setting all properties.
function thickness_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in calc.
function calc_Callback(hObject, eventdata, handles)
set(hObject, 'Enable', 'off');
pause(0.01)

%obtain species
species=get(handles.species,'string');
value=get(handles.species,'value');
species=cell2mat(species(value));

%load stopping range tables
if strcmp(species,'H')
    Alu=load('AlusrimH.txt');
    CR=load('CR39srimH.txt');
elseif strcmp(species,'C')
    Alu=load('AlusrimC.txt');
    CR=load('CR39srimC.txt');
end
    
E_alu=Alu(:,1); %ion energy in keV
dE_electron_alu=Alu(:,2); %stopping in units of  keV / micron 
dE_ion_alu=Alu(:,3);
range_alu=Alu(:,4); %range in um

E_CR39=CR(:,1); %ion energy in keV
dE_electron_CR39=CR(:,2); %stopping in units of  keV / micron 
dE_ion_CR39=CR(:,3);
range_CR39=CR(:,4); %range in um

%interpolate stopping range tables
E=(1:1000000)';  %keV steps
%alu
dEdx_electron(:,1)=interp1(E_alu,dE_electron_alu,E);
dEdx_ion(:,1)=interp1(E_alu,dE_ion_alu,E);
range_int(:,1)=interp1(E_alu,range_alu,E);
%cr39
dEdx_electron(:,2)=interp1(E_CR39,dE_electron_CR39,E);
dEdx_ion(:,2)=interp1(E_CR39,dE_ion_CR39,E);
range_int(:,2)=interp1(E_CR39,range_CR39,E);

%obtain layers and thicknesses
layer1=get(handles.layer1,'string');
value=get(handles.layer1,'value');
layer1=cell2mat(layer1(value));
if strcmp(layer1,'Alu')
    layer1index=1;
elseif strcmp(layer1,'CR39')
    layer1index=2;
end
thickness1=str2double(get(handles.thickness1,'string'));

layer2=get(handles.layer2,'string');
value=get(handles.layer2,'value');
layer2=cell2mat(layer2(value));
if strcmp(layer2,'Alu')
    layer2index=1;
elseif strcmp(layer2,'CR39')
    layer2index=2;
end
thickness2=str2double(get(handles.thickness2,'string'));

index=0;
E_in=9;
um=0;
E1=0;
while um<=thickness1+thickness2
    index=index+1;
    E_in=E_in+1;
    E_out=E_in;
    um=0;
    while E_out>=100 && um<=thickness1+thickness2
        um=um+1;
        if um<=thickness1
            layerindex=layer1index;
        elseif um>thickness1
            layerindex=layer2index;
        end
        E_out=round(E_out-dEdx_electron(E_out-9,layerindex)+dEdx_ion(E_out-9,layerindex));
    end
    %range(index,1)=E_in;
    %range(index,2)=um;
    if um==thickness1+1 && thickness1>0
        E1=E_in;
    end
end
set(handles.Elayer1,'string',[num2str(round(E1/1e3*100)/100),'MeV'])
set(handles.Elayer2,'string',[num2str(round(E_in/1e3*100)/100),'MeV'])
set(hObject,'string','Calculate','foregroundcolor','black')
set(hObject, 'Enable', 'on');

% --- Executes on selection change in species.
function species_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function species_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
