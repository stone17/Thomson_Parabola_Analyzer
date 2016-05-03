function varargout = select_s(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @select_s_OpeningFcn, ...
                   'gui_OutputFcn',  @select_s_OutputFcn, ...
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


% --- Executes just before select_s is made visible.
function select_s_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

try
load('user.mat')
p=load('periodic.mat','-mat','periodic');

for a=1:length(a_i)
    charge = sprintf('charge%d', a);
    charge = handles.(charge);

    iso = sprintf('iso%d', a);
    iso = handles.(iso);
    
    ion = sprintf('ion%d', a);
    ion = handles.(ion);
    
    mass=a_i(a,1);
    ion_selected=find(p.periodic(:,2)==mass);
    charge_selected=a_i(a,2);
       
    if mass==1 || mass==2
        set(iso,'String',{p.periodic(ion_selected,2),p.periodic(ion_selected,2)+1,p.periodic(ion_selected,2)+2});
        if mass==1
            set(charge,'Value',1)
        elseif mass==2
            set(charge,'Value',2)
        else
            set(charge,'Value',3)
        end
        set(charge,'String',['1','+']);
        set(ion,'value',ion_selected+1)
    elseif mass>3
        chargestate=p.periodic(ion_selected,1);
        for cs=1:chargestate
            chargestates{cs}=[num2str(cs),'+'];
        end
        set(charge,'Value', charge_selected);
        set(charge,'String',chargestates);

    	set(iso,'value',1);
        set(iso,'String',{p.periodic(ion_selected,2)});
        set(ion,'value',ion_selected+1)
    end
end
end
% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = select_s_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes on selection change in ion1.
function ion_Callback(hObject, eventdata, handles)
str = get(hObject, 'String');
val = get(hObject,'Value');
select=get(hObject, 'Tag');
select=str2double(select(4));

charge = sprintf('charge%d', select);
charge = handles.(charge);

iso = sprintf('iso%d', select);
iso = handles.(iso);


p=load('periodic.mat','-mat','periodic');
ion=val-1; %mass number
%mass=p.periodic(ion,2);

if ion==1
    set(iso,'String',{p.periodic(ion,2),p.periodic(ion,2)+1,p.periodic(ion,2)+2});
    set(charge,'Value',1)
    set(charge,'String',['1','+']);
elseif ion<1
    set(iso,'value',1);
    set(charge,'value',1);
	set(iso,'String','-');
    set(charge,'String','-');
else
    chargestate=p.periodic(ion,1);
    for cs=1:chargestate
        chargestates{cs}=[num2str(cs),'+'];
    end

    set(charge,'Value',chargestate)
    set(charge,'String',chargestates);

	set(iso,'value',1);
	set(iso,'String',{p.periodic(ion,2)});
end
export_Callback(hObject,eventdata, handles)

% --- Executes on selection change in charge1.
function charge_Callback(hObject, eventdata, handles)
export_Callback(hObject,eventdata, handles)

% --- Executes on selection change in iso1.
function iso_Callback(hObject, eventdata, handles)
export_Callback(hObject,eventdata, handles)

function pops_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function export_Callback(hObject,eventdata, handles)
index=0;
list='';
for a=1:7
    charge = sprintf('charge%d', a);
    charge = handles.(charge);

    iso = sprintf('iso%d', a);
    iso = handles.(iso);
    
    ion = sprintf('ion%d', a);
    ion = handles.(ion);
    if ~isnan(str2double(get(iso,'string')))
        index=index+1;
        
        isoval=get(iso,'val');
        isostr=get(iso,'str');
        mass=str2double(isostr(isoval));
        
        chval=get(charge,'val');
        
        a_i(index,1)=mass;
        a_i(index,2)=chval;
        

        species=get(ion,'str');
        species=species(get(ion,'val'));
        species=cell2mat(species(1));
        if mass==2
            species='D';
        elseif mass==3
            species='T';
        end
        list=[list,' ',species(1),num2str(chval)];
    end
end
save('user.mat','a_i','list')