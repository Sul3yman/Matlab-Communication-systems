function [RTT,RTTsaveFlag]=Transmitter(Channel,bitStream, FrameLength)

%<Transmitter> Transmitts the information bits in (bitstream) to the server

%using the available channel in (Channel)

%

%   Function inputs:

%       <Channel>       - Object used for identifying the channel between 

%                         the client and the server

%       <bitStream>     - stream of information bits that should be 

%                         transmitted between the client and the server

%       <FrameLength>   - variable used to specify the number of information

%                         bits per packet

%   

%   Function output: 

%       <RTT>           - round-trip time (RTT) of correctly acknowledged

%                         packets.

%       <RTTsaveFlag>   - 1: save RTT, 0: do not save RTT (default)

%

%

%   Author(s):  Erik Steinmetz, Katharina Hausmair 

%   Email:      estein@chalmers.se, hausmair@chalmers.se

%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Algorithm description             %

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%

%   Here is given an example of how to implement and stop and go ARQ 

%   transmitter (update this section with your actual implementation): 

%

%     1. retrieve current package according to packet counter

%     2. embedd packet in frame with header/trailer bits: complete the

%        function pkg2frame 

%     3  send frame

%     4. stop and wait for ack (set timer)

%     5. if error free ack is received and R_next=(S_last+1)mod 2, 

%           - update packet counter and S_last 

%           - save recorded round-trip time 

%           - go to step 1 for retrieval of next packet 

%     6. if time-out go to step 3 to retransmit current frame

%     7. if all data received terminate connection  

%

%     

%   The greener the code, the better the environment! (Use comments!)

%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% REVISION HISTORY                  %

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1.00, 2013-11-29, Erik Steinmetz     : First version...

% 2.00, 2014-12-10, Erik Steinmetz     : Second version...

% 3.00, 2016-01-12, Katharina Hausmair : comments changed/added

% 4.00, 2022-01-14, Chouaib Bencheikh.L: addition of an ouput that allows

%                                        saving recorded round-trip time

% 5.00, 2023-12-20, Morteza Barzegar Astanjin: changed for being first part
% of project
%------------- BEGIN CODE - DO NOT EDIT HERE --------------

% Split the bitstream into packages
nBitsPacket = FrameLength;                             %number of bits per packet(eg. 2,4,10,11,13,20,22,25,26,44,50,52,55,65,100,110,130,143,286,572...,14300]
nPackets = length(bitStream)/nBitsPacket;              %number of packets to split bitstream into
if mod(nPackets,1)>0
 error('You must specify FrameLength such that number of packets is a positive integer')
end
packages = double(reshape(bitStream,nPackets,nBitsPacket)); 
RTT=NaN(nPackets,1); % variable to store recorded Round-Trip Time (RTT)

ipacket = 1;         %initialize packet counter
S_last = 0;          %initialize sequence number for transmitter

%------------- BEGIN EDITING HERE --------------
%error('You must complete the Transmitter function!!!!!') % comment this line to implement the transmitter

RTTsaveFlag=1;               % set it to '1' if you want to save recorded RTT.
nBitsOverhead = [2]; %specify the number of overhead bits here (scalar)

while ipacket<=size(packages,1)

    %1 retrieve current packet according to packet counter
    packet = packages(ipacket,:);
    
    %2 embedd packet in frame: use the code to create frames (add
    %  header and trailer, ...): you must use the function pkg2frame!
    %  it forms your frame as [header, packet,parity]
    % it also implements parity adding for error checking in reciever
    frame = pkg2frame(packet, S_last);
    
    %3 Send current frame
    LengthOfHeader = 1; %used when reading the ackframe from receiver
    
    WriteToChannel(Channel, frame)
    disp(['Transmit packet: ' num2str(ipacket)])

    %4-6 stop and wait for ack: implement the rest of the transmitter side
    timer=tic;  %start timer
    t_out=0.5;  %temporary timeout value for the timer
   
    while true  %loop will run until either timeout or correctly received ack
        if toc(timer)>t_out %breaks loop if timeout
            break;
        end

        Y = ReadFromChannel(Channel, LengthOfHeader);   %reads ack from receiver
        if Y==bitxor(S_last,1)  %if R_next = S_last+1 (bitwise), increase ipacket and S_last (bitwise) by 1 and break loop
            ipacket=ipacket+1;  %move on to next packet
            S_last=bitxor(S_last,1); %bit addition by 1. 1 becomes 0 and 0 becomes 1
            break;
        end
    end
    
    % stop-and-wait ARQ protocol here 
   
    % hint: use timer = tic; to start a timer, and time = toc(timer); to

    % get the time that has passed since timer was started 

    % you can also use that to record the RTT 
         
end

disp([num2str(RTT)])

%------------- STOP EDITING HERE --------------

%7 terminate connection

% Send FIN message to the receiver a few times before shutting down the

% connection
ExpectedLengtOfFrame=nBitsPacket+nBitsOverhead;
TerminateConnection('Tx',Channel,ExpectedLengtOfFrame,S_last);
end

%--------------- END CODE ----------------

