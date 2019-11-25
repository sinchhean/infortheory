function shBits = hamming_decoder(rBits)
%============== PERFORM DECODING ON THE MESSAGE =================

    % Examine rBits 7 bits i.e., one codeword at a time and
    % calculate the syndrome z by multiplying those 7 bits with
    % the parity check matrix H (be reminded of the dimension of H).
    % From the obtained z, check the table and see which bit needs
    % to be reversed. Reverse that bit to obtain a legit codeword and
    % trace back the original 4 bits from that codeword.
    % Write the result into an array shBits
    % which corresponds to the decoded message
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
        H = [1 1 1 0 1 0 0; 0 1 1 1 0 1 0; 1 0 1 1 0 0 1];
        z_syndrom = {
                       {[0 0 1],7},{[0 1 0],6},{[0 1 1],4},{[1 0 0],5},...
                       {[1 0 1],1},{[1 1 0],2},{[1 1 1],3}
                    };
        shBits = zeros([1,length(rBits)*4/7]);
        for i = 1:length(rBits)/7
            r = rBits(1+(i-1)*7:7*i);
            z = mod(H*r',2);
            z = z';
            for j = 1:length(z_syndrom)             
                if isequal(z,z_syndrom{j}{1})
                    r(z_syndrom{j}{2}) = ~r(z_syndrom{j}{2});
                    rBits(1+(i-1)*7:7*i) = r;
                    break;
                end
            end
            for k = 1:length(codebook)
                if isequal(r,codebook{k}{2})
                	shBits(1+(i-1)*4:4*i) = codebook{k}{1};
                    break;
                end                    
            end
        end
end