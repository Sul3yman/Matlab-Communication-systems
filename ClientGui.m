function varargout = ClientGui(varargin)
% CLIENTGUI MATLAB code for ClientGui.fig
%      CLIENTGUI, by itself, creates a new CLIENTGUI or raises the existing
%      singleton*.
%
%      H = CLIENTGUI returns the handle to a new CLIENTGUI or the handle to
%      the existing singleton*.
%
%      CLIENTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CLIENTGUI.M with the given input arguments.
%
%      CLIENTGUI('Property','Value',...) creates a new CLIENTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ClientGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ClientGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ClientGui

% Last Modified by GUIDE v2.5 04-Dec-2014 16:02:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ClientGui_OpeningFcn, ...
    'gui_OutputFcn',  @ClientGui_OutputFcn, ...
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


% --- Executes just before ClientGui is made visible.
function ClientGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ClientGui (see VARARGIN)

clc;
clear Channel


bwpic=imread('HeidiLamarr.png');
% axes(handles.TransmitImageBox);
% imshow(bwpic)

set(handles.TransmissionSummary,'String','');
imshow(bwpic, 'Parent', handles.TransmitPicture);


% Choose default command line output for ClientGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes ClientGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ClientGui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in TransmittData.
function TransmittData_Callback(hObject, eventdata, handles)
% hObject    handle to TransmittData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;
clear Channel;
Line2={'----------------------------------------------'};

TransmissionAttempts=str2num(get(handles.edit1,'string'));
FrameLength=str2num(get(handles.edit2,'string'));
BitErrors=NaN(1,TransmissionAttempts);
TransmissionTime=NaN(1,TransmissionAttempts);

%client interface is created
Channel=tcpip('localhost', 30000, 'NetworkRole', 'client');
set(Channel,'TransferDelay','off')
set(Channel,'OutputBufferSize',15000)
set(Channel,'InputBufferSize',4000)
set(Channel,'TimeOut',5)


try
    fopen(Channel)
    
    pause(0.1)
    fwrite(Channel, [TransmissionAttempts FrameLength], 'double')
    
    fclose(Channel);
    
catch me
    
    display('Can not connect. Server not running')
    clear Channel
    return
    
end


%Source data  
bwpic=imread('HeidiLamarr.png');
%imshow(bwpic)
infobitStream=reshape(bwpic,1,[]);

RTT=NaN(length(infobitStream)/FrameLength,TransmissionAttempts);

for i=1:TransmissionAttempts
    
    disp(['Initiating Tranmission Attempt ', num2str(i)])
    
    
    %% Establish client interface and connect to server (Initialize channel)
    if i==1
        pause(1.5)
    else
        pause(3)
    end
    fopen(Channel);
    
    
    
    %% Get Source data (data that should be transmitted)
    %Source data  
     bwpic=imread('HeidiLamarr.png');
    %imshow(bwpic)
     infobitStream=reshape(bwpic,1,[]);
    
    
    %% Transmitt data
    TransmitTimer=tic;
    [recordRTT,sFlag]=Transmitter(Channel,infobitStream, FrameLength);
    
    %% Out put params
    
    BitErrors(i)=fread(Channel, 1, 'int8');
    TransmissionTime(i)=toc(TransmitTimer);
    
    RTT(:,i)=recordRTT;
    
    %% close connection to server
    fclose(Channel);
    
    disp(['All Data sent in ' num2str(TransmissionTime(i)) ' sec'])
    
    display(Line2{:});
    
end


AverageBitErrors=sum(BitErrors)/TransmissionAttempts;
AverageTransmissionTime=sum(TransmissionTime)/TransmissionAttempts;
S1={['Number of transmissions: ' num2str(TransmissionAttempts)]};
S2={['Average number of bit errors: ' num2str(AverageBitErrors)]};
S3={['Average transmission time: ' num2str(AverageTransmissionTime)]};
sSummary=[S1;S2;S3];
set(handles.TransmissionSummary,'String',sSummary(1:end));

% save round-trip time (RTT)
if sFlag==1
    save_name=['SavedRTT/RTT_N',num2str(FrameLength),'_',...
                    datestr(now,'ddmmmHHMMSS'),'.mat'];
    save(save_name,'RTT')
    disp('Recorded Round-trip time (RTT) was saved.')
else
    disp('Round-trip time (RTT) was not saved.')
        disp('Set "RTTsaveFlag=1" in Tranmitter.m, to save it.')
end

clear Channel



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
