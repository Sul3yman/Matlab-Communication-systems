function [bError] = ErrorCheck(data)
%<ErrorCheck> check received frame for errors

%   Function inputs:
%       <data>                - received data
%       <TypeOfErrorCheck>    - string for the type of error check that should be
%                               performed(eg. 'parity')
%
%   Function output:
%       <bError>    - boolean variable that is [0: when no error, 1: when error]
%
%
%   Author(s):  Erik Steinmetz, Katharina Hausmair
%   Email:      estein@chalmers.se, hausmair@chalmers.se
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REVISION HISTORY                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1.00, 2013-11-29, Erik Steinmetz: First version...
% 2.00, 2014-12-10, Erik Steinmetz: Second version...

%------------- BEGIN CODE --------------
% the code assumes data a column vector
TypeOfErrorCheck='parity';
switch TypeOfErrorCheck
    case 'parity'
        bError=mod(nnz(data),2);
        
    case 'ICS'
        %data=data';
        parity_dec=bi2de(data(length(data)-16+1:end),'left-msb');
        packet=data(1:length(data)-16);
        app=16-mod(length(packet),16);
        partitions=buffer(applen(packet,app+length(packet)),16);
        partitions_dec=bi2de(partitions','left-msb');
        if mod(sum(partitions_dec)+parity_dec,2^16-1)==0
            bError=0;          %Implement error check here 
        else  
            bError=1;
        end
    otherwise
        error('Invalid error check!')       
end

