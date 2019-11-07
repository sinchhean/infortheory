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
        R = input('Input the repetition rate (must be odd e.g., 3, 5, 7): ');
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

%======================== REPETITION CODING ===============================

    % Repeat each element in sBits (i.e., pixel array) R times
    % to get a new array tBits (transmitted Bits)
        tBits = zeros([1,R*length(sBits)]);
        for i = 1:length(sBits)
            tBits(1+(i-1)*R:R*i) = sBits(i);
        end

%========= TRANSMISSION OF CODED MESSAGE THROUGH BINARY CHANNEL ===========
    
    % Flip each element in tBits with probability f
        fBits = rand(1,length(tBits)) <= f;
    % and get a (corrupted) array rBits (received Bits)
        rBits = bitxor(tBits,fBits);
    
%============== PERFORM DECODING ON THE CORRUPTED MESSAGE =================

    % Examine the received array (rBits) R bits at a time
    % and use majority voting to decide if these R bits
    % should be decoded as bit 0 or bit 1
    % Write the decisions sequentially into an array shBits
    % which corresponds to the decoded message
        shBits = zeros([1,length(sBits)]);
        for i = 1:length(sBits)
            bits = rBits(1+(i-1)*R:R*i);
            if mode(bits) == 0
                shBits(i) = 0;
            else
                shBits(i) = 1;
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
        fid = fopen([filepath, '\' , name, '_Repetition_f=', num2str(f,2), '_R=', num2str(R), ext],'w');
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