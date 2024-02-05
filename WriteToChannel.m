function WriteToChannel(Channel,X)

fwrite(Channel, X, 'int8')    %Send via TCPIP socket

end

