function tBits = r3_encoder(sBits)
    R = 3;
    %======================== REPETITION CODING ===============================

        % Repeat each element in sBits (i.e., pixel array) R times
        % to get a new array tBits (transmitted Bits)
            tBits = zeros([1,R*length(sBits)]);
            for i = 1:length(sBits)
                tBits(1+(i-1)*R:R*i) = sBits(i);
            end

end