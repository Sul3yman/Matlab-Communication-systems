function varargout = ServerGui(varargin)
% SERVERGUI MATLAB code for ServerGui.fig
%      SERVERGUI, by itself, creates a new SERVERGUI or raises the existing
%      singleton*.
%
%      H = SERVERGUI returns the handle to a new SERVERGUI or the handle to
%      the existing singleton*.
%
%      SERVERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SERVERGUI.M with the given input arguments.
%
%      SERVERGUI('Property','Value',...) creates a new SERVERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ServerGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ServerGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ServerGui

% Last Modified by GUIDE v2.5 01-Dec-2014 17:21:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ServerGui_OpeningFcn, ...
    'gui_OutputFcn',  @ServerGui_OutputFcn, ...
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


% --- Executes just before ServerGui is made visible.
function ServerGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ServerGui (see VARARGIN)


clc;
clear Channel
set(handles.ServerInfo,'String','');
%pic=imread('Shannon3.jpg');
%whitepic=im2bw(pic);
%whitepic(:)=1;
%axes(handles.ReceivedImageBox);
%imshow(whitepic)

% Choose default command line output for ServerGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ServerGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ServerGui_OutputFcn(hObject, eventdata, handles)
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
clear Channel;
Data=[];

OutPut={};
Line1={'Receiver ready'};
Line2={'----------------------------------------------'};
display(Line1{:});
display(Line2{:});
OutPut=[OutPut;Line1;Line2];
set(handles.ServerInfo,'String',OutPut(1:end));
drawnow;

Channel=tcpip('0.0.0.0', 30000, 'NetworkRole', 'server');
set(Channel,'TransferDelay','off')
set(Channel,'OutputBufferSize',4000)
set(Channel,'InputBufferSize',15000)
set(Channel,'TimeOut',5)



fopen(Channel);
while isempty(Data)
    Data=fread(Channel, 2, 'double');
end
TransmissionAttempts=Data(1);
FrameLength=Data(2);
fclose(Channel);


for i=1:TransmissionAttempts
    
    
    Line1={['Receiving: Transmission Attempt ' num2str(i)]};
    Line2={'----------------------------------------------'};
    OutPut=[OutPut;Line1];
    
    display(Line1{:})
    display(Line2{:});
    if length(OutPut)<=10;
        set(handles.ServerInfo,'String',OutPut(1:end));
    else
        set(handles.ServerInfo,'String',OutPut(end-10:end));
    end
    drawnow;
    
    
    %% Establish server interface (Initialize channel)
    %Open a connection. This will not return until a connection is received,
    %i.e. a client has connected
    
    fopen(Channel);
    flushinput(Channel);                % Important to flush the Channel, 
                                        % otheriwse FIN messages are read 
                                        % from the Channel when a new
                                        % tranmission starts, causing
                                        % problems when multiple
                                        % tranmissions are run at the same
                                        % time. (Chouaib Bencheikh L.)
   
    %% Receive
    [ReceivedInfoBitStream]=Receiver(Channel,FrameLength);
    
    %Plot Received picture
    receivedpic=reshape(ReceivedInfoBitStream,143,100);
    %figure(2)
    axes(handles.ReceivedPic);
    imshow(receivedpic);
    %title('Received data')
    %shg
    
    %Load source data to calculate actual bit errors
    %Source data    
    bwpic=imread('HeidiLamarr.png');
    
    SentInfoBitStream=reshape(bwpic,1,[]);
    
    ActualBitErrors=sum(SentInfoBitStream~=ReceivedInfoBitStream);
    
    
    Line2={['Data was received with ' num2str(ActualBitErrors) ' bit errors']};
    Line3={'----------------------------------------------'};
    display(Line2{:})
    display(Line3{:})
    drawnow;
    
    
    OutPut=[OutPut;Line2;Line3];
    if length(OutPut)<=10;
        set(handles.ServerInfo,'String',OutPut(1:end));
    else
        set(handles.ServerInfo,'String',OutPut(end-10:end));
    end
    
    
    %% close connection
    fwrite(Channel, ActualBitErrors, 'int8')
    pause(0.5)
    
    fclose(Channel);
    
    
end


Line1={'Server Closed'};
OutPut=[OutPut;Line1];

display(Line1{:})

if length(OutPut)<=10;
    set(handles.ServerInfo,'String',OutPut(1:end));
else
    set(handles.ServerInfo,'String',OutPut(end-10:end));
end

clear Channel




% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(hObject);
%close all force
