function varargout = prin2(varargin)
% PRIN2 MATLAB code for prin2.fig
%      PRIN2, by itself, creates a new PRIN2 or raises the existing
%      singleton*.
%
%      H = PRIN2 returns the handle to a new PRIN2 or the handle to
%      the existing singleton*.
%e cl

%      PRIN2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PRIN2.M with the given input arguments.
%
%      PRIN2('Property','Value',...) creates a new PRIN2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before prin2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to prin2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help prin2

% Last Modified by GUIDE v2.5 20-Dec-2018 13:35:31

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @prin2_OpeningFcn, ...
                   'gui_OutputFcn',  @prin2_OutputFcn, ...
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


% --- Executes just before prin2 is made visible.
function prin2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prin2 (see VARARGIN)

% Choose default command line output for prin2
handles.output = hObject;
%set(handles.button_field, 'enable', 'off');
%set(handles.edit2, 'enable', 'off');
%set(handles.button_anato, 'enable', 'off');
%set(handles.edit3, 'enable', 'off');

% Update handles structure

guidata(hObject, handles);

% UIWAIT makes prin2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prin2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


   
% --- Executes on button press in button_data.
function button_data_Callback(hObject, eventdata, handles)
% hObject    handle to button_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uigetfile({'*.txt';'*.mat'},'File Selector');
if FileName==0, return, end

set(handles.listbox3,'String',strcat(PathName,FileName));% ruta
pt= load(fullfile(PathName,FileName));  %# pass file path as string
fn=fieldnames(pt);
%cp =pt.cp20;
eval(['cp=pt.' fn{1} ';']);
%cp1=getfield(pt,fn{1})
%%cp =pt.V';
[x,y]=size(cp);

clear pt

setappdata(0,'cp',cp);
guidata(hObject, handles);
FileInfo = dir(fullfile(PathName,FileName));
FileSize = FileInfo.bytes;
waitH    = waitbar(0, 'Loading your data..');
chunk  = 1e3;
nChunk = ceil(FileSize / chunk);
iChunk = 0;
while iChunk < nChunk
  iChunk = iChunk + 1;
  waitbar(iChunk / nChunk, waitH);
  pause(1);
  guidata(hObject, handles);
  %data = fread(inFID, chunk, '*uint8');
  %fwrite(outFID, data, 'uint8');
end

[filepath,name,ext] = fileparts(strcat(PathName,FileName));

preg='false';
if strcmp(ext,'.txt') % arreglar .mat
    if isreal(cp)
            set(handles.frec, 'value', 1);
            set(handles.frec,'enable', 'off');    
            set(handles.tiempo,'enable', 'off');
     else
            preg='true';
     end
% %     else
% %         set(handles.frec,'enable', 'on');    
% %         set(handles.tiempo,'enable', 'on');        
% %     end
% % else
% %     if strcmp(ext,'.txt') 
% %         aux=get(handles.tipo,'SelectedObject');    
% % 
% %     end
else
    if strcmp(ext,'.txt') && y==1
            set(handles.tiempo, 'value', 1);
            set(handles.tiempo,'enable', 'off');    
            set(handles.frec,'enable', 'off');
    else
            preg='true';
    end   
end
if ~preg
    set(handles.frec,'enable', 'false');    
    set(handles.tiempo,'enable', 'on'); 

end
aux=get(handles.tipo,'SelectedObject');
if aux.Value > 0
    TF=get(aux,'String');
    setappdata(0,'TF',TF);
    close(waitH);
    set(handles.button_field, 'enable', 'on');
else
    h = msgbox('Selección: Tiempo o Frecuencia');
end
set(handles.ne,'String',x);
set(handles.nr,'String',y);

%% validación tiempo-frecuencia
%set(handles.button_field, 'enable', 'on');
%set(handles.button_field, 'enable', 'on');
function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_field.
function button_field_Callback(hObject, eventdata, handles)
% hObject    handle to button_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uigetfile('*.mat','Select mat file');
if FileName==0, return, end
KeLeorig = load( fullfile(PathName,FileName) );   %# pass file path as string


%% validacion de Ke y LE
KeLe.Ke = KeLeorig.Ke;
KeLe.Le = KeLeorig.Le;
setappdata(0,'KeLe',KeLe);

% muestra la ruta
set(handles.edit2,'String',strcat(PathName,FileName));
% # de canales y generadores
if isfield(KeLeorig,'ChannNumber')
    set(handles.nef,'String',KeLeorig.ChannNumber);
else
    set(handles.nef,'String',size(KeLe.Ke,1));    
end
if isfield(KeLeorig,'GridPoints')
    set(handles.ng,'String',KeLeorig.GridPoints);
else
     set(handles.ng,'String',size(KeLe.Ke,2));
end

if isfield(KeLeorig,'AveRef')
    Reference=KeLeorig.AveRef; 
    set(handles.ref_lead,'String',KeLeorig.Reference); 
else
    Reference = 0;
    set(handles.ref_lead,'value',-1); 
end

% modelo
%set(handles.MCMC, 'enable', 'on');
%set(handles.OW, 'enable', 'on');
%set(handles.conf, 'enable', 'on');
set(handles.button_anato, 'enable', 'on');
clear KeLeorig; 

function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_anato.
function button_anato_Callback(hObject, eventdata, handles)
% hObject    handle to button_anato (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uigetfile('*.mat','Select mat file');
if FileName==0, return, end
modelo = load( fullfile(PathName,FileName) );   %# pass file path as string
% muestra la ruta
set(handles.edit3,'String',strcat(PathName,FileName));
models = modelo.models;
C = squeeze(struct2cell( models ));
%mod = find(cell2mat(cellfun(@(x) double(x), C(5,:),'UniformOutput',false)));
%model0 = find(cell2mat(cellfun(@(x) double(x), C(4,:),'UniformOutput',false)));
set(handles.atlas,'String',modelo.AtlasFileName);
%handles.models=models;
VS=modelo.Vol_Suf;
switch VS
    case 'volume'
            set(handles.volume, 'value', 1);
    case 'surface'
            set(handles.surface, 'value', 1);        
end
%handles.mod=1:size(models,2);
setappdata(0,'models',models);
setappdata(0,'VS',VS);
mod=1:90;
model0 = [35    55    79    84    86    90];
setappdata(0,'mod',mod);
setappdata(0,'model0',model0);
handles.NStructures=modelo.NStructures;
handles.NPoints=modelo.NPoints;
set(handles.struct,'String',handles.NStructures);
set(handles.points,'String',handles.NPoints);
set(handles.radiobutton_markov,'enable','on');
set(handles.radiobutton_OW,'enable','on');
set(handles.burning,'enable','on');
set(handles.samples,'enable','on');
set(handles.burning, 'String', 4000);
set(handles.samples, 'String', 3000);
set(handles.value_OW, 'String', 0);set(handles.OCW, 'value', 1);
set(handles.stop, 'enable', 'on');
set(handles.evidence, 'enable', 'on');
set(handles.view, 'enable', 'on');
set(handles.button_output, 'enable', 'on');
set(handles.average, 'enable', 'on');
set(handles.var_solution, 'enable', 'on');

set(handles.average, 'value', 1);
set(handles.var_solution, 'value', 0);


function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_output.
function button_output_Callback(hObject, eventdata, handles)
% hObject    handle to button_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%[filename, pathname] = uiputfile(... {'*.png';'*.jpg';'*.*'},... 'Save as');
[filename, foldername] = uiputfile({'*.mat';'*.txt'},'Save as');
set(handles.text2,'String',strcat(foldername,filename));
%complete_name = fullfile(foldername, filename);    
[filepath,name,ext] = fileparts(strcat(foldername,filename));
format=ext(2:end);
setappdata(0,'format',format);
%% 
Save.Path=foldername;
Save.Name = filename;
setappdata(0,'Save',Save);
set(handles.run, 'enable', 'on');

function ne_Callback(hObject, eventdata, handles)
% hObject    handle to ne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ne as text
%        str2double(get(hObject,'String')) returns contents of ne as a double


% --- Executes during object creation, after setting all properties.
function ne_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nr_Callback(hObject, eventdata, handles)
% hObject    handle to nr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nr as text
%        str2double(get(hObject,'String')) returns contents of nr as a double


% --- Executes during object creation, after setting all properties.
function nr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ng_Callback(hObject, eventdata, handles)
% hObject    handle to ng (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ng as text
%        str2double(get(hObject,'String')) returns contents of ng as a double


% --- Executes during object creation, after setting all properties.
function ng_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ng (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nef_Callback(hObject, eventdata, handles)
% hObject    handle to nef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nef as text
%        str2double(get(hObject,'String')) returns contents of nef as a double


% --- Executes during object creation, after setting all properties.
function nef_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in view.
function view_Callback(hObject, eventdata, handles)
% hObject    handle to view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of view
models=getappdata(0,'models');
T = struct2table(models, 'AsArray', true);
%[x,y]=size(T);
%Tabla = table('Size',size(T));

b=T.indices;
for K = 1 : length(b)
  thisdata = num2cell(b{K});
  [x,y]=size(thisdata);
  data(K) = x;
end
data=data';
datos=[T.names num2cell(data)  num2cell(T.prior) num2cell(T.selected) num2cell(T.included)];
setappdata(0,'datos',datos);
set(tabla,'Visible', 'on');
%set(tabla,'Datos', datos);

data_nueva=getappdata(0,'data_nueva');
disp(data_nueva)

function struct_Callback(hObject, eventdata, handles)
% hObject    handle to struct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of struct as text
%        str2double(get(hObject,'String')) returns contents of struct as a double


% --- Executes during object creation, after setting all properties.
function struct_CreateFcn(hObject, eventdata, handles)
% hObject    handle to struct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function points_Callback(hObject, eventdata, handles)
% hObject    handle to points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of points as text
%        str2double(get(hObject,'String')) returns contents of points as a double


% --- Executes during object creation, after setting all properties.
function points_CreateFcn(hObject, eventdata, handles)
% hObject    handle to points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in status.
function status_Callback(hObject, eventdata, handles)
% hObject    handle to status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns status contents as cell array
%        contents{get(hObject,'Value')} returns selected item from status


% --- Executes during object creation, after setting all properties.
function status_CreateFcn(hObject, eventdata, handles)
% hObject    handle to status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

reff=get(handles.average,'Value');

Options1=0;Options2=0;
if reff == 1
    Options1 = 0; 
else
    Options1 = 1; 
end
setappdata(0,'Options1',Options1);


aux=get(handles.tipo2,'SelectedObject');
band=get(aux,'String');
Options2 = 0;
if strcmp(band,'Markov Chain Monte Carlo (MCMC)')
    %set(MCMC,'Visible', 'on');
    MET='MC'; 
    %burning=getappdata(0,'burning');
    burning=str2num(get(handles.burning,'String'));%getappdata(0,'burning');
    %setappdata(0,'burning',burning);
    samples=str2num(get(handles.samples,'String'));%getappdata(0,'sampling');
    %setappdata(0,'sampling',sampling);
    %WarningStopAutomatic=getappdata(0,'stop');
    %setappdata(0,'sampling',sampling);
    WarningStopAutomatic=get(handles.stop,'value');%getappdata(0,'sampling');
    if WarningStopAutomatic == 1
        Options2 = 0;
    else
        Options2 = 1; 
    end;
else
     MET='OW';
     %set(OW,'Visible', 'on');
end
setappdata(0,'Options2',Options2);
setappdata(0,'MET',MET);
models=getappdata(0,'models');
mod=getappdata(0,'mod');
KeLe=getappdata(0,'KeLe');
cp=getappdata(0,'cp');
%cp=cp*100;

aux=get(handles.burning,'String');
burning=str2num(aux);
%burning=getappdata(0,'burning');
aux=get(handles.samples,'String');
samples=str2num(aux);
%samples=getappdata(0,'samples');
Options(1)=getappdata(0,'Options1');Options(2)=getappdata(0,'Options2');
model0=getappdata(0,'model0');
Save=getappdata(0,'Save');
MET=getappdata(0,'MET');
%OWL=getappdata(0,'ol');
aux=get(handles.value_OW,'String');
OWL=str2num(aux);
VS=getappdata(0,'VS');
TF=getappdata(0,'TF');
format=getappdata(0,'format');
plot=get(handles.evidence,'Value');
setappdata(0,'plot',plot);
Plot=getappdata(0,'plot');
%cp=cp(1:120,:);
model0 = [];
mod = 1:size(models,2);
clearvars -except models mod KeLe cp burning samples Options model0 Save MET OWL VS TF format Plot;
%cp(:,1:11)=-1;
[Jmod, plotearf] = BMA_fMRIG(models, mod, KeLe, cp, burning, samples, Options,model0, Save, MET, OWL, VS, TF, format,Plot);

% --- Executes on button press in Reference.
function average_Callback(hObject, eventdata, handles)
% hObject    handle to Reference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Reference


% --- Executes on button press in evidence.
function evidence_Callback(hObject, eventdata, handles)
% hObject    handle to evidence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of evidence


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3


% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%imread('database_process.png')

% --- Executes on button press in conf.
function conf_Callback(hObject, eventdata, handles)
% hObject    handle to conf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% % aux=get(handles.tipo2,'SelectedObject');
% % band=get(aux,'String');
% % if strcmp(band,'Markov Chain Monte Carlo (MCMC)')
% %     set(MCMC,'Visible', 'on');
% %     MET='MC'; 
% %     burning=getappdata(0,'burning');
% %     setappdata(0,'burning',burning);
% %     samples=getappdata(0,'samples');
% %     setappdata(0,'samples',samples);
% %     WarningStopAutomatic=getappdata(0,'stop');
% %     setappdata(0,'samples',samples);
% %     if WarningStopAutomatic == 1, Options2 = 0;
% %     else Options2 = 1; end;
% %     setappdata(0,'Options2',Options2);
% % else
% %      MET='OW';
% %      set(OW,'Visible', 'on');
% % end
% % setappdata(0,'MET',MET);
% % set(handles.button_anato, 'enable', 'on');
% % set(handles.evidence, 'enable', 'on');
% % a=1;


% --- Executes on button press in Reference.
function Reference_Callback(hObject, eventdata, handles)
% hObject    handle to Reference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Reference


% --- Executes on button press in var_solution.
function var_solution_Callback(hObject, eventdata, handles)
% hObject    handle to var_solution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of var_solution



function burning_Callback(hObject, eventdata, handles)
% hObject    handle to burning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of burning as text
%        str2double(get(hObject,'String')) returns contents of burning as a double


% --- Executes during object creation, after setting all properties.
function burning_CreateFcn(hObject, eventdata, handles)
% hObject    handle to burning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function listbox5_Callback(hObject, eventdata, handles)
% hObject    handle to samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of samples as text
%        str2double(get(hObject,'String')) returns contents of samples as a double


% --- Executes during object creation, after setting all properties.
function listbox5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in stop.
function stop_Callback(hObject, eventdata, handles)
% hObject    handle to stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stop


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8



function samples_Callback(hObject, eventdata, handles)
% hObject    handle to samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of samples as text
%        str2double(get(hObject,'String')) returns contents of samples as a double


% --- Executes during object creation, after setting all properties.
function samples_CreateFcn(hObject, eventdata, handles)
% hObject    handle to samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function warming_Callback(hObject, eventdata, handles)
% hObject    handle to warming (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of warming as text
%        str2double(get(hObject,'String')) returns contents of warming as a double


% --- Executes during object creation, after setting all properties.
function warming_CreateFcn(hObject, eventdata, handles)
% hObject    handle to warming (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton_markov.
function radiobutton_markov_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_markov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_markov
set(handles.burning, 'String', 4000);
set(handles.samples, 'String', 3000);
set(handles.value_OW, 'String', 0);
set(handles.MCMC_Set, 'visible', 'on');
set(handles.OW_Set, 'visible', 'off');
guidata(hObject, handles);


% --- Executes on button press in radiobutton_OW.
function radiobutton_OW_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_OW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_OW
set(handles.burning, 'String', 0);
set(handles.samples, 'String', 0);
set(handles.MCMC_Set, 'visible', 'off');
set(handles.OW_Set, 'visible', 'on');
set(handles.OCW, 'value', 1);
set(handles.value_OW, 'String', 3);
guidata(hObject, handles);



function edit21_Callback(hObject, eventdata, handles)
% hObject    handle to atlas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of atlas as text
%        str2double(get(hObject,'String')) returns contents of atlas as a double


% --- Executes during object creation, after setting all properties.
function atlas_CreateFcn(hObject, eventdata, handles)
% hObject    handle to atlas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in OCW.
function OCW_Callback(hObject, eventdata, handles)
% hObject    handle to OCW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OCW contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OCW

index_selected = get(handles.OCW,'Value');
switch index_selected
    case 1
        set(handles.value_OW, 'String',3);
    case 2
        set(handles.value_OW, 'String',20);
    case 3
        set(handles.value_OW, 'String',150);
    case 4
        set(handles.value_OW, 'String',200);    
    case 5
        set(handles.value_OW, 'String',250);
        set(handles.value_OW, 'enable','on');
end


% --- Executes during object creation, after setting all properties.
function OCW_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OCW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function value_OW_Callback(hObject, eventdata, handles)
% hObject    handle to value_OW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of value_OW as text
%        str2double(get(hObject,'String')) returns contents of value_OW as a double


% --- Executes during object creation, after setting all properties.
function value_OW_CreateFcn(hObject, eventdata, handles)
% hObject    handle to value_OW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ref_lead_Callback(hObject, eventdata, handles)
% hObject    handle to ref_lead (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ref_lead as text
%        str2double(get(hObject,'String')) returns contents of ref_lead as a double


% --- Executes during object creation, after setting all properties.
function ref_lead_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref_lead (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
