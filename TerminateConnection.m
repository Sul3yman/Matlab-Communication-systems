function TerminateConnection(sMode,Channel,varargin)
%<TerminateConnection> Function for termination of the connection.Its hard 
% to say Good bye (more info Leon-Garcia pp. 615)
%
%   Function inputs:
%       <sMode>         - String with specifying if it si the Tx or Rx that
%                         should be terminated     
%       <Channel>       - Object used for identifying the channel between 
%                         the client and the server
%       <varargin>      - Other required input parameters. 
%                         For Rx: nBitsPacket,
%                                 R_next
%                                 infoframe
%                         For Tx: nBitsPacket  
%                                 S_last  
%                                      
%   
%   Function output: 
%
%
%   Author(s):  Erik Steinmetz, Katharina Hausmair 
%   Email:      estein@chalmers.se, hausmair@chalmers.se
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Algorithm description             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   1.
%
%   The greener the code, the better the environment! (Use comments!)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REVISION HISTORY                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1.00, 2014-12-10, Erik Steinmetz: First version...
% 2.00, 2016-02-26, Katharina Hausmair: made code independent of
% ErrorCheck(...) and pkg2frame(...) to avoid problems with student's
% implementations
% 3.00, 2022-01-21, Chouaib Bencheikh L.: added a timer to ensure
% termination of the function even in case of failure to receive a FIN

  
% Procedure for terminating Connection on Receiver side  
if strcmp(sMode,'Rx')
    R_next=varargin{2};
    ackframe=varargin{3};
    nBitsPacket=varargin{1};
    FIN=0;
    SetTimer=tic;               %Timer to monitor if the channel is idle. 
                                %This is used to ensure that the receiver
                                %terminates connection if FIN messages
                                %were not correctly received and the 
                                % channel is idle for certain time.
                                %This ensures a more robust termination
                                %condition of the connection at the
                                %receiver side.

    while FIN<=1 && (toc(SetTimer)<1)
        Y=ReadFromChannel(Channel,nBitsPacket);
        if ~isnan(Y)    %if data received          
            SetTimer=tic;           % Data reeceived--> reset timer
            
            bError=mod(sum(Y),2);
            S_last=Y(1);
            if~bError && S_last==R_next 
                FIN=FIN+1;                            % When 2 FIN received (we can go ahead and quit)
                disp('FIN received correctly')
            else
                disp('Retarnsmit ACK of the last frame')
                WriteToChannel(Channel,ackframe)       % No FIN received (resend last ACK)
            end
        end
    end
    if FIN<2            % If timer expires without receiving 2 FIN messages --> 
                        % Forecefully terminate connection after sending an ACK of the last tranmitted frame 
        WriteToChannel(Channel,ackframe) 
        disp('Connection Terminated after timer expiration')
    end

    % Procedure for terminating Connection on Transmiter side
% (Send FIN message a few time and then quit)    
elseif strcmp(sMode,'Tx')   
    nBitsPacket = varargin{1};
    S_last = varargin{2};   
    packet = ones(nBitsPacket-2,1)';
    FIN = [S_last packet mod(sum([S_last packet]),2)];
    for iFin = 1:10
        disp(['Sent FIN:' num2str(iFin), ' Slast:', num2str(S_last)])
        WriteToChannel(Channel,FIN)
    end    
end

end
