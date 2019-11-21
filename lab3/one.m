clear variables
clc

%=============== READ TEXT FILE =======================
% Get the full file path and read the bmp file into rawBits array
disp('Select a text file')
[file,path] = uigetfile('*.txt');
fid = fopen([path,file]);
rawBytes = fread(fid,'*ubit8')';
rawBytes = int16(rawBytes);
fclose('all');

%=================Prompt for Huffman coding=============
choice = menu('Do you want to use Huffman coding?','Yes','No');
usehuffman = 0;
if choice==1
   disp("use Huffman coding");
   usehuffman = 1;
elseif choice==2 
   disp("no Huffman coding");
else
    disp("The program stopped");
    return ;
end

choice = menu('Choose choice for ECC.','no ECC','Hamming','R3');
noECC = 0;
usehamming = 0;
useR3 = 0;
if choice==1
   disp("no ECC");
   noECC = 1;
elseif choice==2
   disp("use Hamming coding");
   usehamming = 1;
elseif choice==3
    disp("use R3 coding");
    useR3 = 1;
else
    disp("The program stopped");
    return ;
end
% Get other necessary parameters
%f = input('Input the flipping probability of binary symmetric channel (0 <= f <= 1): ');
%bitsPerByte = 8;