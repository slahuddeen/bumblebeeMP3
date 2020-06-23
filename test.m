function varargout = test(varargin)
% TEST MATLAB code for test.fig
%      TEST, by itself, creates a new TEST or raises the existing
%      singleton*.
%
%      H = TEST returns the handle to a new TEST or the handle to
%      the existing singleton*.
%
%      TEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEST.M with the given input arguments.
%
%      TEST('Property','Value',...) creates a new TEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before test_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to test_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help test

% Last Modified by GUIDE v2.5 30-Dec-2018 20:54:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;

gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @test_OpeningFcn, ...
                   'gui_OutputFcn',  @test_OutputFcn, ...
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


% --- Executes just before test is made visible.
function test_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to test (see VARARGIN)

% Choose default command line output for test
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
global playlist
global i 
i = 0;

global player
player = {}

set(handles.slider2,'Value',0.5);
set(handles.playbtn,'enable','off');
set(handles.pausebtn,'enable','off');
set(handles.resumebtn,'enable','off');
set(handles.stopbtn,'enable','off');

%handles.output = hObject;
%files = dir(fullfile(pwd,'matlabold','*.jpg'));
%for x = 1 : length(files)
%    handles.images{x} = imread(fullfile(pwd,'matlabold',files(x).name));
%end
%set(handles.listbox1,'string',{files.name});
%guidata(hObject, handles)

handles.output = hObject;
%files = dir(fullfile(pwd,'matlabold','*.wav'));
%for x = 1 : length(files)
%    handles.images{x} = imread(fullfile(pwd,'matlabold',files(x).name));
%end

% UIWAIT makes test wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = test_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function playsong(hObject, eventdata, handles, submitedsample)
global player
global index
global value
global duration
global total_samples

%gets song from playlist
index = get(handles.listbox1, 'String');
value = get(handles.listbox1, 'Value');
[y,Fs] = audioread(char(index(value)));

player = audioplayer(y, Fs);

handles.y        = y';
handles.Fs       = Fs;
handles.timeSec  = length(y)/Fs;
handles.atSample = submitedsample;
start = submitedsample;

%calls to function to increase the volume
a = @computeSquare;
b = a(y,hObject, eventdata, handles);
handles.player = audioplayer(b, Fs);


%prepares graph
guidata(hObject,handles);
cla(handles.axes3);
hold(handles.axes3,'on');
xlim(handles.axes3,[1 length(y)]);


%https://uk.mathworks.com/matlabcentral/answers/95933-how-can-i-play-audio-in-matlab-8-1-r2013a-while-simultaneously-moving-a-marker-on-a-plot-of-the-au


%player.TimerFcn = {@plotMarker, player, gcf, plotdata};
%player.TimerPeriod = 0.01
%x = player.CurrentSample;


rawduration = audioinfo(char(index(value)))
duration = rawduration.Duration
total_samples = rawduration.TotalSamples
sec = mod(duration,60)
mins = (duration/60)


set(handles.timertxt, 'String' ,fix(mins));
set(handles.sectxt, 'String' ,fix(sec));



set(handles.player,'TimerFcn',{@timerCallback,handles.figure1}, 'TimerPeriod', 0.1);



set(handles.pausebtn,'enable','on');
set(handles.stopbtn,'enable','on');

play(handles.player,start);




function timerCallback(hObject, event, hFig)
global duration
global total_samples
handles = guidata(hFig);

% find the current sample
currSample = get(hObject,'CurrentSample');

% get all the sound data
data    = handles.y(handles.atSample+1:currSample);

% plot the most recent data to the graph
plot(handles.axes3,handles.atSample+1:currSample,data);

% update the handles object
handles.atSample = currSample;
guidata(hFig,handles);

% update the slider
if currSample > 1
    sliderVal = min(1.0,currSample/length(handles.y));
    set(handles.slider1,'Value',sliderVal);
    
    
    thing =  (currSample/total_samples)*duration;
    mins =  round(thing/60);
    sec = round(mod(thing,60));
    disp(total_samples)
    %for v = 1:sec:60
     % set(handles.currsectxt,'String',v);      
    %end
    
    set(handles.currmins,'String',mins); 
    set(handles.currsectxt,'String',sec);
    

end

%https://uk.mathworks.com/matlabcentral/answers/222105-make-the-slider-move-as-the-music-is-playing


function y = computeSquare(x,hObject, event, handles)
volslider=get(handles.slider2,'value');
Volume = volslider*5;
y = x*Volume;

function volume(hObject, eventdata, handles)
global player
global NewStart
global value
global index
player = handles.player;
NewStart=get(player,'CurrentSample')+1;
[x,Fs]=audioread(char(index(value)));
x=x(NewStart:end,:); 
Volume=get(handles.slider2,'value');
player=audioplayer(x*Volume,Fs);

% --- 
Executes on button press in playbtn.
function playbtn_Callback(hObject, eventdata, handles)
     playsong(hObject, eventdata, handles, 0)



function import(hObject, eventdata, handles)

temp = uigetfile({"*.wav";"*.mp4"})
[y,Fs] = audioread(temp);
global player

player = audioplayer(y, Fs);
handles.output = hObject;
%index = get(handles, thing);
newlistarray = get(handles.listbox1, 'String');
newlistarray{end+1} = temp ; 

set(handles.listbox1, 'String' ,newlistarray);
guidata(hObject, handles);
%display(player, Timerfcn)

 
 
function remove(hObject, eventdata, handles)
global value

newlistarray = get(handles.listbox1, 'String');
value = get(handles.listbox1, 'Value');
newlistarray(value) = [];

set(handles.listbox1, 'String' ,newlistarray);


% --- Executes on button press in pausebtn.
function pausebtn_Callback(hObject, eventdata, handles)
% hObject    handle to pausebtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.resumebtn,'enable','on');
pause(handles.player);



% --- Executes on button press in importbtn.
function importbtn_Callback(hObject, eventdata, handles)
% hObject    handle to importbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
import(hObject, eventdata, handles)
set(handles.playbtn,'enable','on');



% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider








% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
if isplaying(handles.player)
   pause(handles.player);
   
   currSample = get(handles.player,'CurrentSample');

    playsong(hObject, eventdata, handles, currSample);
disp(currSample);
end




% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in stopbtn.
function stopbtn_Callback(hObject, eventdata, handles)
% hObject    handle to stopbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global player 
stop(handles.player);
clear sound;




% --- Executes when selected cell(s) is changed in uitable1.
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)




%selection = eventdata.Indices(:,1);
%handles.currSelection = selection;
%guidata(hObject,handles);
%refreshDisplays(table(selection,:),handles,2);


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
  %handles.output = hObject;
  %index = get(handles.listbox1,'value');
%imshow(handles.images{index});
  %guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in resumebtn.
function resumebtn_Callback(hObject, eventdata, handles)
% hObject    handle to resumebtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global player;
resume(handles.player);


% --- Executes on button press in remove.
function remove_Callback(hObject, eventdata, handles)
% hObject    handle to remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
remove(hObject, eventdata, handles)
