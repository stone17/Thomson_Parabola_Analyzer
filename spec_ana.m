function varargout = spec_ana(varargin)
% SPEC_ANA M-file for spec_ana.fig
%      SPEC_ANA, by itself, creates a new SPEC_ANA or raises the existing
%      singleton*.
%
%      H = SPEC_ANA returns the handle to a new SPEC_ANA or the handle to
%      the existing singleton*.
%
%      SPEC_ANA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPEC_ANA.M with the given input arguments.
%
%      SPEC_ANA('Property','Value',...) creates a new SPEC_ANA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before spec_ana_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to spec_ana_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help spec_ana

% Last Modified by GUIDE v2.5 03-Jun-2010 17:35:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @spec_ana_OpeningFcn, ...
                   'gui_OutputFcn',  @spec_ana_OutputFcn, ...
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


% --- Executes just before spec_ana is made visible.
function spec_ana_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to spec_ana (see VARARGIN)

% Choose default command line output for spec_ana
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes spec_ana wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = spec_ana_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in signal.
function signal_Callback(hObject, eventdata, handles)
% hObject    handle to signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of signal


% --- Executes on button press in bg.
function bg_Callback(hObject, eventdata, handles)
% hObject    handle to bg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bg


% --- Executes on button press in sub.
function sub_Callback(hObject, eventdata, handles)
% hObject    handle to sub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sub


% --- Executes on button press in linear.
function linear_Callback(hObject, eventdata, handles)
% hObject    handle to linear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of linear


% --- Executes on button press in ce.
function ce_Callback(hObject, eventdata, handles)
% hObject    handle to ce (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
