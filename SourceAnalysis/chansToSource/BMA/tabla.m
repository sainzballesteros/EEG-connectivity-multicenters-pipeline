function varargout = tabla(varargin)
% TABLA MATLAB code for tabla.fig
%      TABLA, by itself, creates a new TABLA or raises the existing
%      singleton*.
%
%      H = TABLA returns the handle to a new TABLA or the handle to
%      the existing singleton*.
%
%      TABLA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TABLA.M with the given input arguments.
%
%      TABLA('Property','Value',...) creates a new TABLA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tabla_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tabla_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tabla

% Last Modified by GUIDE v2.5 16-Oct-2018 16:20:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tabla_OpeningFcn, ...
                   'gui_OutputFcn',  @tabla_OutputFcn, ...
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


% --- Executes just before tabla is made visible.
function tabla_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tabla (see VARARGIN)

% Choose default command line output for tabla
handles.output = hObject;
dat=getappdata(0,'datos');
set(handles.tabla,'Data',dat);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes tabla wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tabla_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data_nueva= get(handles.tabla,'Data');
setappdata(0,'data_nueva',data_nueva);
close
