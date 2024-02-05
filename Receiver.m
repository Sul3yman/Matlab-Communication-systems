function [datastream]=Receiver(Channel, FrameLength)
%<Receiver> Receive the information bits sent by the Transmitter via the 
%channel (Channel)
%
%   Function inputs:
%       <Channel>       - Object used for identifying the channel between 
%                         the client and the server
%       <FrameLength>   - variable used to specify the number of 
%                         information bits per packet
%   
%   Function output: 
%       <datastream>    - received information bits that should be returned
%                         to the upper layers in the server
%
%
%   Author(s):  Erik Steinmetz, Katharina Hausmair 
%   Email:      estein@chalmers.se, hausmair@chalmers.se
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Algorithm description             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Here is given an example of how to implement an stop and wait ARQ 
%   receiver (update this section with your actual implementation): 
%
%     1. Check for data
%     2. if frame correctly received and not earlier received, store and
%        update R_next (sequence number)
%     3. if frame correctly received send acknowledgement frame
%     4. if all data received terminate connection  
%
%   The greener the code, the better the environment! (Use comments!)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REVISION HISTORY                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1.00, 2013-11-29, Erik Steinmetz      : First version...
% 2.00, 2014-12-10, Erik Steinmetz      : Second version...
% 3.00, 2016-01-14, Katharina Hausmair  : changed comments and some variable
%                                         names
% 4.00, 2016-02-26, Katharina Hausmair  : changed call to TerminateConnection 
% 5.00, 2023-12-20, Morteza Barzegar Astanjin: changed for being first part
% of project

%------------- BEGIN CODE - DO NOT EDIT HERE --------------
lengthBitStream = 14300;                  %total length of information bitstream that should be received
nBitsPacket = FrameLength;                %bits per packet 
nPackets = lengthBitStream/nBitsPacket;   %number of packages to receive
if mod(nPackets,1)>0
 error('You must specify FrameLength such that number of packets is a positive integer')
end
infopackets = NaN(nPackets,nBitsPacket);  %variable to store received packages in
ipacket = 1;                              %initialize packet counter 
R_next = 0;                               %initialize next frame expected (sequence number)

%------------- START EDITING HERE --------------
error('You must complete the Receiver function!!!!!') % comment this line to implement the receiver


while ipacket<=nPackets 
    
    %1 check for data
    nBitsOverhead = [32]; %define the number of overhead bits here (scalar)
    ExpectedLengtOfFrame = nBitsPacket+nBitsOverhead; %this is the length of the frame we should receive
    Y = ReadFromChannel(Channel, ExpectedLengtOfFrame);
    
    if ~isnan(Y) %if data received
        disp(['Received packet: ' num2str(ipacket)])
        %2-3 if data correctly received send ack and store data (if not received earlier)       
        %implement rest of receiver side of stop-and-wait ARQ protocol below (incl. error check etc.)
        WriteToChannel(Channel,ackframe)
        %send ack by using: WriteToChannel(Channel,ackframe) where ackframe is your ackknowledgement frame
        %Use the function [bError] = ErrorCheck(data) for error check of received data, it uses parity check 

    end   
end

%------------- DO NOT EDIT HERE --------------
%4. terminate connection 
%Wait for 2 FIN messages from the transmitter before shutting down the connection 
TerminateConnection('Rx',Channel,ExpectedLengtOfFrame,R_next,ackframe);
%Function output
datastream=reshape(infopackets, 1, []);
end
