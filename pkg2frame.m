function frame = pkg2frame(packet, header)
%<pkg2frame> create info frame by adding header and error check bits (eg. parity bit)
%
%   Function inputs:
%       <packet>   - information packet that should be framed
%       <header>   - bits that should be included in header (eg. sequence number)
%       <TypeOfErrorCheck>    - string for the type of error detection (eg. 'parity')
%
%   Function output:
%       <frame>    - information frame
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
% 2.00, 2016-03-01, Katharina Hausmair: added TypeOfErrorCheck
TypeOfErrorCheck='parity';
switch TypeOfErrorCheck
    case 'ICS'
        
        app=16-mod(length(packet)+1,16);
        partitions=buffer(padarray([header,packet].',app,'post').',16);
        partitions_dec=bi2de(partitions','left-msb');
        parity_dec=(2^16-1)-mod(sum(partitions_dec),2^16-1);
        parity=de2bi(parity_dec,16,'left-msb');
            
        
    case 'parity'
        %1 calculate parity bit
        if mod(nnz([header,packet]),2)==0
            parity=0;
        else
            parity=1;
        end
    otherwise
          error('Invalid error check!')        
end
%2 assemble the frame

frame = [header, packet,parity];
