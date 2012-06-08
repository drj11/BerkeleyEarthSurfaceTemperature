function varargout = DatasetManager(varargin)
% DATASETMANAGER M-file for DatasetManager.fig
%      DATASETMANAGER, by itself, creates a new DATASETMANAGER or raises the existing
%      singleton*.
%
%      H = DATASETMANAGER returns the handle to a new DATASETMANAGER or the handle to
%      the existing singleton*.
%
%      DATASETMANAGER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATASETMANAGER.M with the given input arguments.
%
%      DATASETMANAGER('Property','Value',...) creates a new DATASETMANAGER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DatasetManager_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DatasetManager_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DatasetManager

% Last Modified by GUIDE v2.5 25-Jan-2011 09:29:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DatasetManager_OpeningFcn, ...
                   'gui_OutputFcn',  @DatasetManager_OutputFcn, ...
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


% --- Executes just before DatasetManager is made visible.
function DatasetManager_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DatasetManager (see VARARGIN)

% Choose default command line output for DatasetManager
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

updateRegistratedDatasetList();
makeUpdate();

% UIWAIT makes DatasetManager wait for user response (see UIRESUME)
% uiwait(handles.DatasetManager);


% --- Outputs from this function are returned to the command line.
function varargout = DatasetManager_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in data_list.
function data_list_Callback(hObject, eventdata, handles)
% hObject    handle to data_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

makeUpdate();


% Hints: contents = cellstr(get(hObject,'String')) returns data_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from data_list


% --- Executes during object creation, after setting all properties.
function data_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to data_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

reg = getRegistrationStructure();
list = keys( reg );

set( hObject, 'String', list );

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in version_list.
function version_list_Callback(hObject, eventdata, handles)
% hObject    handle to version_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

makeUpdate();

% Hints: contents = cellstr(get(hObject,'String')) returns version_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from version_list


% --- Executes during object creation, after setting all properties.
function version_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to version_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in add_button.
function add_button_Callback(hObject, eventdata, handles)
% hObject    handle to add_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

reg = getRegistrationStructure();
temperatureGlobals;

h = findobj( 'tag', 'data_list' );
v = get( h, 'value' );
list = get( h, 'string' );
name = list{v};

h = findobj( 'tag', 'datatype_list' );
dataset = reg( name );
types = keys( dataset.types );

pos = get( h, 'value' );
type_name = types{pos};
type = dataset.types( types{pos} );
version = keys( type.version );

h = findobj( 'tag', 'version_list' );
pos = get( h, 'value' );
ver_name = version{pos};


h = findobj( 'tag', 'existing_list' );
list = get( h, 'String' );
new_item = ['(Pending) ' name ' : ' type_name ' : ' ver_name]; 

bad = false;
for k = 1:length(list)
    if strcmp( list{k}, new_item )
        bad = true;
    end
end
if ~bad
    list{end+1} = new_item;
else
    return;
end

list = sort(list);
set(h, 'String', list);

data = guidata( h );
if ~isfield( data, 'download' )
    data.download = {{},{},{}};
end
data.download{1}{end+1} = name;
data.download{2}{end+1} = type_name;
data.download{3}{end+1} = ver_name;

guidata( h, data );


% --- Executes on button press in execute_button.
function execute_button_Callback(hObject, eventdata, handles)
% hObject    handle to execute_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h = findobj( 'tag', 'existing_list' );
list = guidata( h );

h = findobj( 'tag', 'DatasetManager' );
close(h);

if isfield( list, 'download' ) 
    list = list.download;
    downloadRegisteredDataSet( list{1}, list{2}, list{3} );
end


% --- Executes on selection change in existing_list.
function existing_list_Callback(hObject, eventdata, handles)
% hObject    handle to existing_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns existing_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from existing_list


% --- Executes during object creation, after setting all properties.
function existing_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to existing_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in datatype_list.
function datatype_list_Callback(hObject, eventdata, handles)
% hObject    handle to datatype_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

makeUpdate();

% Hints: contents = cellstr(get(hObject,'String')) returns datatype_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from datatype_list


% --- Executes during object creation, after setting all properties.
function datatype_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to datatype_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function data_description_CreateFcn(hObject, eventdata, handles)
% hObject    handle to data_description (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function makeUpdate()

reg = getRegistrationStructure();
temperatureGlobals;

h = findobj( 'tag', 'data_list' );
v = get( h, 'value' );
list = get( h, 'string' );
name = list{v};

h = findobj( 'tag', 'datatype_list' );
dataset = reg( name );
types = keys( dataset.types );
set( h, 'string', types );

pos = get( h, 'value' );
if pos > length( types )
    set( h, 'value', 1 );
    pos = 1;
end
type_name = types{pos};
type = dataset.types( types{pos} );
version = keys( type.version );

h = findobj( 'tag', 'version_list' );

pos = get( h, 'value' );
set( h, 'string', version );
if pos > length(version)
    set( h, 'value', 1 );
    pos = 1;
end
ver_name = version{pos};
ver = type.version( version{pos} );

h = findobj( 'tag', 'data_description' );
set( h, 'string', dataset.desc );

h = findobj( 'tag', 'revision_description' );
set( h, 'string', [ver.desc char(13) char(10) num2str(ver.size) ' bytes - ' datestr( ver.updated ) ]);

h1 = findobj( 'tag', 'status_text' );
h2 = findobj( 'tag', 'add_button' );

if isempty( ver.path ) || ver.size == 0
    set(h1, 'string', 'Not Available' );
    set(h2, 'enable', 'off' );
else
    try
        rdd = registeredDataSet( name, type_name, ver_name );        
        if md5hash( rdd ) == ver.hash
            set(h1, 'string', 'Local Copy is Current' );
            set(h2, 'enable', 'off' );
        else
            set(h1, 'string', 'Local Copy Needs Updating' );
            set(h2, 'enable', 'on' ); 
        end
    catch
        set(h1, 'string', 'Available for Download' );
        set(h2, 'enable', 'on' );
    end
end


% --- Executes on button press in cancel_button.
function cancel_button_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h = findobj( 'tag', 'DatasetManager' );
close(h);
