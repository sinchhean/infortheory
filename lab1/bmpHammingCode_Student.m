clear variables
clc

%=============== READ THE BMP FILE AND OTHER INPUTS =======================
    % Get the full file path and read the bmp file into rawBits array
        [file,path] = uigetfile('*.bmp');
        fid = fopen([path,file]);
        rawBits = fread(fid,'*ubit1')';
        fclose('all');

    % Get other necessary parameters
        f = input('Input the flipping probability of binary symmetric channel (0 <= f <= 1): ');
        bitsPerByte = 8;

%================== EXTRACT THE PIXEL ARRAY FROM THE ARRAY ================
    
    % Find the starting point and ending point of pixel array
        dataOffset = b2d(rawBits(10*bitsPerByte+1:14*bitsPerByte));       % Offset (in BYTES) from the file's start to the pixel array *
        imWidth = b2d(rawBits(18*bitsPerByte+1:22*bitsPerByte));          % Width of the image in pixels 
        imHeight = b2d(rawBits(22*bitsPerByte+1:26*bitsPerByte));         % Height of the image in pixels
        bitDepth = b2d(rawBits(28*bitsPerByte+1:30*bitsPerByte));         % Number of bits per pixel
        imSize = imHeight*ceil(imWidth*bitDepth/32)*32;                   % Size of the pixel array (in BITS) *
    
    % Extract the header bits into the array headerBits
        headerBits = rawBits(1:dataOffset*bitsPerByte);
    % Extract the pixel array into the array sBits
        sBits = rawBits(dataOffset*bitsPerByte+1:dataOffset*bitsPerByte+imSize);
    % Extract the trailer bits into the array trailerBits
        trailerBits = rawBits(dataOffset*bitsPerByte+imSize+1:end);

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
        tBits = zeros([1,length(sBits)*7/4]);
        for i = 1:length(sBits)/4
            k = sBits(1+(i-1)*4:4*i);
            for j = 1:length(codebook)
                if isequal(k,codebook{j}{1})
                    tBits(1+(i-1)*7:7*i) = codebook{j}{2};
                    break;
                end
            end
        end
%========= TRANSMISSION OF CODED MESSAGE THROUGH BINARY CHANNEL ===========
    
    % Flip each element in tBits with probability f
        fBits = rand(1,length(tBits)) <= f;
    % and get a (corrupted) array rBits (received Bits)
        rBits = bitxor(tBits,fBits);
%============== PERFORM DECODING ON THE CORRUPTED MESSAGE =================

    % Examine rBits 7 bits i.e., one codeword at a time and
    % calculate the syndrome z by multiplying those 7 bits with
    % the parity check matrix H (be reminded of the dimension of H).
    % From the obtained z, check the table and see which bit needs
    % to be reversed. Reverse that bit to obtain a legit codeword and
    % trace back the original 4 bits from that codeword.
    % Write the result into an array shBits
    % which corresponds to the decoded message
        H = [1 1 1 0 1 0 0; 0 1 1 1 0 1 0; 1 0 1 1 0 0 1];
        z_syndrom = {
                       {[0 0 1],7},{[0 1 0],6},{[0 1 1],4},{[1 0 0],5},...
                       {[1 0 1],1},{[1 1 0],2},{[1 1 1],3}
                    };
        rBits_tmp = rBits;
        shBits = zeros([1,length(sBits)]);
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
%============= COMPARE THE ORIGINAL WITH THE DECODED MESSAGE ==============
    
    % Compare the two array sBits and shBits (which should be of same size)
    % and count the number of bit differences between the two
        shBits = uint8(shBits);
        errBits = sum(bitxor(sBits,shBits));
        disp(errBits);
    % Calculate the bit error rate 
    % i.e., number of errorneous bit / number of uncoded bits
        disp(errBits/length(sBits));
    
%========== OUTPUT THE DECODED IMAGE INTO A READABLE BMP FILE =============
    
    % Re-append the headerBits and trailerBits to the decoded message shBits
    % to get an array shRawBits corresponding to a standard, readable BMP file
        shRawBits = [headerBits, shBits, trailerBits];
    % Write the output to the same directory as the original image
        [filepath,name,ext] = fileparts([path,file]);
        fid = fopen([filepath, '\' , name, '_Hamming74_f=', num2str(f,2), ext],'w');
        fwrite(fid,shRawBits,'ubit1');
        fclose('all');
    % Write a function b2d to convert a bit array into a decimal number,
    % assuming that the leftmost bit is the least significant bit
        function m = b2d(x)
            k = length(x);
            A = zeros([1,k]);
            for i = 1:k
                A(i) = 2^(i-1);
            end
            m = sum(A.*double(x)); 
        end