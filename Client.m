% Client Script
function [BitErrors, TransmissionTime]=Client
close all
clear all
clc

TransmissionAttempts=2;
BitErrors=NaN(1,TransmissionAttempts);
TransmissionTime=NaN(1,TransmissionAttempts);

%client interface is created 
Channel=tcpip('localhost', 30000, 'NetworkRole', 'client');
set(Channel,'TransferDelay','off')
set(Channel,'OutputBufferSize',15000)
set(Channel,'InputBufferSize',4000)

fopen(Channel);
fwrite(Channel, TransmissionAttempts, 'int8') 
pause(0.1)
fclose(Channel);


for i=1:TransmissionAttempts
    
    


%% Establish client interface and connect to server (Initialize channel)
fopen(Channel);



%% Get Source data (data that should be transmitted)
%Source data
bwpic=imread('HeidiLamarr.png');
imshow(bwpic)
title('Source data that should be transmitted')
infobitStream=reshape(bwpic,1,[]);


%% Transmitt data 
TransmitTimer=tic;
Transmitter(Channel,infobitStream)

%% Out put params

BitErrors(i)=fread(Channel, 1, 'int8');
TransmissionTime(i)=toc(TransmitTimer);


%% close connection to server
fclose(Channel);
disp(['All Data sent in ' num2str(TransmissionTime(i)) ' sec'])

pause(1)

end

end