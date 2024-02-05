function Y=ReadFromChannel(Channel, FrameLength)

bPacketDrops=1; %Add Packet Drops
bBitErrors=1;   %Add Bit Errors

if Channel.BytesAvailable < FrameLength %Not enough data available
    
    Y=NaN; % return NaN
else
    
    %Read Data
    X=fread(Channel, FrameLength, 'int8'); %If available read data
   
    
    %Bit Errors
    if bBitErrors
        %Implementation of Channel
        bit_error_prob=1E-3;
        bit_error=rand(length(X),1)<bit_error_prob; %vector with 0 and 1, a 1 on position k indicates that the kth bit is fliped.
        
        %resulting bit sequence with bit errors
        Y=mod(X+bit_error,2);
    else
        Y=X; %Return without bit errors
    end
    
    
    %Packet Drops
    if bPacketDrops
        packet_drop_prob=0.015;%0.5;%0.015;
        
        if rand<packet_drop_prob
            Y=NaN; %Packet Dropped
        end
    end
    
    

end




