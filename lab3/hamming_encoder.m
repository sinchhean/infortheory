function tBits = hamming_encoder(sBits)
    %======================== HAMMING CODING ==================================

        % Examine sBits 4 bits at a time. From each 4 bits, generate
        % the corresponding codeword via either a codebook or
        % multiplying the 4 bits with the generator matrix.
        % Write the results into the array tBits (transmitted Bits)
            codebook ={
                        {[0 0 0 0],[0 0 0 0 0 0 0]},{[0 0 0 1],[0 0 0 1 0 1 1]},...
                        {[0 0 1 0],[0 0 1 0 1 1 1]},{[0 0 1 1],[0 0 1 1 1 0 0]},...
                        {[0 1 0 0],[0 1 0 0 1 1 0]},{[0 1 0 1],[0 1 0 1 1 0 1]},...
                        {[0 1 1 0],[0 1 1 0 0 0 1]},{[0 1 1 1],[0 1 1 1 0 1 0]},...
                        {[1 0 0 0],[1 0 0 0 1 0 1]},{[1 0 0 1],[1 0 0 1 1 1 0]},...
                        {[1 0 1 0],[1 0 1 0 0 1 0]},{[1 0 1 1],[1 0 1 1 0 0 1]},...
                        {[1 1 0 0],[1 1 0 0 0 1 1]},{[1 1 0 1],[1 1 0 1 0 0 0]},...
                        {[1 1 1 0],[1 1 1 0 1 0 0]},{[1 1 1 1],[1 1 1 1 1 1 1]}
                      };
            tBits = zeros([1,ceil(length(sBits)*7/4)]);
            for i = 1:length(sBits)/4
                k = sBits(1+(i-1)*4:4*i);
                for j = 1:length(codebook)
                    if isequal(k,codebook{j}{1})
                        tBits(1+(i-1)*7:7*i) = codebook{j}{2};
                        break;
                    end
                end
            end

end