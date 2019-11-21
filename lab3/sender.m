clear variables
clc

bitsPerByte = 8;
%================================================================
%=================Prompt for inputs==============================
%================================================================
%=============== READ TEXT FILE =======================
disp('Select a text file to send')
[file,path] = uigetfile('*.*');
fid = fopen([path,file]);
rawBytes = fread(fid,'*ubit8')';
rawBytes = int16(rawBytes);
fclose('all');
fid = fopen([path,file]);
rawBits = fread(fid,'*ubit1')';
fclose('all');
%=================Prompt for Huffman coding========================
choice = questdlg('Do you want to use Huffman coding?','Lab3','Yes','No','Yes');
usehuffman = 0;
switch choice
    case 'Yes'
        disp("use Huffman coding");
        usehuffman = 1;
    case 'No'
        disp("no Huffman coding");
    otherwise
        disp("The program stopped");
        return ;
end
%=================Prompt for ECC===================================
choice = questdlg('Choose choice for ECC.','Lab3','no ECC','Hamming','R3','no ECC');
noECC = 0;
usehamming = 0;
useR3 = 0;
switch choice
    case 'no ECC'
        disp("no ECC");
        noECC = 1;
    case 'Hamming'
        disp("use Hamming coding");
        usehamming = 1;
    case 'R3'
        disp("use R3 coding");
        useR3 = 1;
    otherwise
        disp("The program stopped");
        return ;
end


%================================================================
%=================Start Execution================================
%================================================================
%================== Compression ==================================
if(usehuffman)
    [node,rawBits] = huffman_encoder(rawBytes);
end
rawBits = uint8(rawBits);
%========================= ECC ==================================
%======================No ECC===================================
if(noECC)
    tBits = rawBits;
end
%=====================hamming encode=============================
if(usehamming)
    tBits = hamming_encoder(rawBits);
end
%=====================R3 encode=============================
if(useR3)
    tBits = r3_encoder(rawBits);
end

%===========SAVE THE TRANSMIT FILE, THE HUFFMAN TREE,=================
%=======AND BINARY FILE OF WAY HOW FILE IS ENCODED ====================

if exist('temp', 'dir')
    rmdir('temp');
    mkdir temp;
else
    mkdir temp;
end
if(usehuffman)
    [filepath,name,ext] = fileparts([path,file]);
    fid = fopen([filepath, '/temp/' , name, ext, '.beforeTransmit.chhean'],'w');
    fwrite(fid,tBits,'ubit1');
    fclose('all');
    compressedFileSize = length(tBits);
    save([filepath, '/temp/', name, '_Tree'],'node','compressedFileSize')
else
    [filepath,name,ext] = fileparts([path,file]);
    fid = fopen([filepath, '/temp/' , name, ext, '.beforeTransmit.chhean'],'w');
    fwrite(fid,tBits,'ubit1');
    fclose('all');
end
key = [usehuffman noECC usehamming useR3];
fid = fopen([filepath, '/temp/' , name, ext, '.chhean.key'],'w');
fwrite(fid,key,'ubit1');
fclose('all');
disp("Message was successfully sent");