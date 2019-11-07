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

%========= TRANSMISSION OF UNCODED MESSAGE THROUGH BINARY CHANNEL ===========
    
    % Flip each element in sBits with probability f
        fBits = uint8(rand(1,length(sBits)) <= f);
    % and get a (corrupted) array rBits (received Bits)
        rBits = bitxor(sBits,fBits);
                

%============= COMPARE THE ORIGINAL WITH THE DECODED MESSAGE ==============
    
    % Compare the two array sBits and rBits (which should be of same size)
    % and count the number of bit differences between the two
        errBits = sum(bitxor(sBits,rBits));
        disp(errBits);
    % Calculate the bit error rate 
    % i.e., number of errorneous bit / number of uncoded bits
        disp(errBits/length(sBits));
    
%========== OUTPUT THE DECODED IMAGE INTO A READABLE BMP FILE =============
    
    % Re-append the headerBits and trailerBits to the decoded message rBits
    % to get an array rRawBits corresponding to a standard, readable BMP file
        rRawBits = [headerBits,rBits,trailerBits];
    % Write the output to the same directory as the original image
        [filepath,name,ext] = fileparts([path,file]);
        fid = fopen([filepath, '\' , name, '_NoCoding_f=', num2str(f,2), ext],'w');
        fwrite(fid,rRawBits,'ubit1');
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