function Server
% Server Script

close all
clear all
clc

TransmissionAttempts=2;
%Accept a connection from any machine on port 30000.
Channel=tcpip('0.0.0.0', 30000, 'NetworkRole', 'server');
set(Channel,'TransferDelay','off')
set(Channel,'OutputBufferSize',4000)
set(Channel,'InputBufferSize',15000)
for i=1:TransmissionAttempts

%% Establish server interface (Initialize channel)




%Open a connection. This will not return until a connection is received,
%i.e. a client has connected
fopen(Channel);



%% Receive
[ReceivedInfoBitStream]=Receiver(Channel);



%Plot Received picture
receivedpic=reshape(ReceivedInfoBitStream,143,100);
figure(2)
imshow(receivedpic)
title('Received data')
shg

%Load source data to calculate actual bit errors 
%Source data
bwpic=imread('HeidiLamarr.png');

SentInfoBitStream=reshape(bwpic,1,[]);

ActualBitErrors=sum(SentInfoBitStream~=ReceivedInfoBitStream);
display('----------------------------------------------')
display(['Data was received with ' num2str(ActualBitErrors) ' bit errors'])

%% close connection 
fwrite(Channel, ActualBitErrors, 'int8') 
pause(0.5)
fclose(Channel);
end
end
