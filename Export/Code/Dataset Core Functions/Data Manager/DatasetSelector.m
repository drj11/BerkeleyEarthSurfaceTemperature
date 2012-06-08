function varargout = DatasetSelector(varargin)
% DATASETSELECTOR MATLAB code for DatasetSelector.fig
%      DATASETSELECTOR, by itself, creates a new DATASETSELECTOR or raises the existing
%      singleton*.
%
%      H = DATASETSELECTOR returns the handle to a new DATASETSELECTOR or the handle to
%      the existing singleton*.
%
%      DATASETSELECTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATASETSELECTOR.M with the given input arguments.
%
%      DATASETSELECTOR('Property','Value',...) creates a new DATASETSELECTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DatasetSelector_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DatasetSelector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DatasetSelector

% Last Modified by GUIDE v2.5 25-Jan-2011 09:15:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DatasetSelector_OpeningFcn, ...
                   'gui_OutputFcn',  @DatasetSelector_OutputFcn, ...
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


% --- Executes just before DatasetSelector is made visible.
function DatasetSelector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DatasetSelector (see VARARGIN)

% Choose default command line output for DatasetSelector
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

buildTable( true );
makeUpdate( );

% UIWAIT makes DatasetSelector wait for user response (see UIRESUME)
% uiwait(handles.DatasetSelector);


% --- Outputs from this function are returned to the command line.
function varargout = DatasetSelector_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in data_menu.
function data_menu_Callback(hObject, eventdata, handles)
% hObject    handle to data_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

makeUpdate( );

% Hints: contents = cellstr(get(hObject,'String')) returns data_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from data_menu


% --- Executes during object creation, after setting all properties.
function data_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to data_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

reg = buildTable( false );
list = keys( reg );

set( hObject, 'String', list );

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in type_menu.
function type_menu_Callback(hObject, eventdata, handles)
% hObject    handle to type_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

makeUpdate( );

% Hints: contents = cellstr(get(hObject,'String')) returns type_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from type_menu


% --- Executes during object creation, after setting all properties.
function type_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to type_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in version_menu.
function version_menu_Callback(hObject, eventdata, handles)
% hObject    handle to version_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

makeUpdate( );

% Hints: contents = cellstr(get(hObject,'String')) returns version_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from version_menu


% --- Executes during object creation, after setting all properties.
function version_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to version_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function command_text_Callback(hObject, eventdata, handles)
% hObject    handle to command_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of command_text as text
%        str2double(get(hObject,'String')) returns contents of command_text as a double


% --- Executes during object creation, after setting all properties.
function command_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to command_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ok_button.
function ok_button_Callback(hObject, eventdata, handles)
% hObject    handle to ok_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

makeUpdate();

reg = getRegistrationStructure();
temperatureGlobals;

h = findobj( 'tag', 'data_menu' );
v = get( h, 'value' );
list = get( h, 'string' );
name = list{v};

h = findobj( 'tag', 'type_menu' );
dataset = reg( name );
types = keys( dataset.types );

pos = get( h, 'value' );
type_name = types{pos};
type = dataset.types( types{pos} );
version = keys( type.version );

h = findobj( 'tag', 'version_menu' );

pos = get( h, 'value' );
ver = version{pos};

disp( ' ' );
disp( 'Use command: ' );
disp( ['   [se, sites] = loadTemperatureData( ''' name ''', ''' type_name ''', ''' ver ''' )'] );
disp( ' ' );
h = findobj( 'tag', 'DatasetSelector' );
close(h);


function makeUpdate( )

reg = buildTable( false );
temperatureGlobals;

h = findobj( 'tag', 'data_menu' );
v = get( h, 'value' );
list = get( h, 'string' );
name = list{v};

h = findobj( 'tag', 'type_menu' );
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

h = findobj( 'tag', 'version_menu' );

pos = get( h, 'value' );
set( h, 'string', version );
if pos > length(version)
    set( h, 'value', 1 );
    pos = 1;
end
ver_name = version{pos};
ver = type.version( version{pos} );

h = findobj( 'tag', 'dataset_text' );
set( h, 'string', dataset.desc );

h = findobj( 'tag', 'version_text' );
set( h, 'string', [ver.desc char(13) char(10) num2str(ver.size) ' bytes - ' datestr( ver.updated ) ]);

if isempty( ver.path )
    h = findobj( 'tag', 'command_text' );
    set(h, 'string', 'Not Available' );
else
    h = findobj( 'tag', 'command_text' );    
    set(h, 'string', ['loadTemperatureData( ''' name ''', ''' type_name ''', ''' ver_name ''' )'] );
end


function result = buildTable( reload ) 

persistent reg;

if ~isempty( reg )  && ~reload
    result = reg;
    return;
end

temperatureGlobals;
reg = getRegistrationStructure;

ks = keys( reg );
for k = 1:length(ks)
    data_record = reg( ks{k} );
    ks2 = keys( data_record.types );
    for j = 1:length(ks2)
        type_record = data_record.types( ks2{j} );
        ks3 = keys( type_record.version );
        for m = 1:length( ks3 );
            entry = type_record.version( ks3{m} );
            
            epath = entry.path;
            epath = strrep( epath, '/', psep );
            epath = strrep( epath, '\', psep );            
            
            pth = [temperature_data_dir psep 'Registered Data Sets' psep epath];
            if ~exist( [pth 'dataset.mat'], 'file' ) || isempty( entry.path );
                type_record.version = remove( type_record.version, ks3{m} );
            end
        end
        if length( type_record.version ) > 0
            data_record.types( ks2{j} ) = type_record;
        else
            data_record.types = remove( data_record.types, ks2{j} );
        end
    end
    if length( data_record.types ) > 0 
        reg( ks{k} ) = data_record;
    else
        reg = remove( reg, ks{k} );
    end
end
        
result = reg;

if length( result ) == 0;
    error( 'No Data Available' );
end
            
            
            
            
            