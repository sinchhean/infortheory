function shBits = r3_decoder(rBits)
       R = 3;
%============== PERFORM DECODING ON THE CORRUPTED MESSAGE =================

    % Examine the received array (rBits) R bits at a time
    % and use majority voting to decide if these R bits
    % should be decoded as bit 0 or bit 1
    % Write the decisions sequentially into an array shBits
    % which corresponds to the decoded message
        shBits = zeros([1,length(rBits)/R]);
        for i = 1:length(rBits)/R
            bits = rBits(1+(i-1)*R:R*i);
            if mode(bits) == 0
                shBits(i) = 0;
            else
                shBits(i) = 1;
            end
        end
end