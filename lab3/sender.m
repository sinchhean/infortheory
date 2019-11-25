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
%=====================hamming encode==========================
%=====================R3 encode=============================
if(noECC)
    tBits = rawBits;
elseif usehamming
    tBits = hamming_encoder(rawBits);
elseif useR3
    tBits = r3_encoder(rawBits);
end
tBits = uint8(tBits);

%=================Prompt for flipping probability=================
prompt = 'Input the flipping probability of binary symmetric channel (0 <= f <= 1): ';
f = inputdlg(prompt,'Lab3',1);
if ~isempty(f)
    f = str2double(f);
else
    disp("The program stopped");
    return;
end

%========= TRANSMISSION OF UNCODED MESSAGE THROUGH BINARY CHANNEL ===========
    % Flip each element in sBits with probability f
        fBits = uint8(rand(1,length(tBits)) <= f);
    % and get a (corrupted) array rBits (received Bits)
        rBits = bitxor(tBits,fBits);
        
%===========SAVE THE TRANSMIT FILE, THE HUFFMAN TREE,=================
%=======AND BINARY FILE OF WAY HOW FILE IS ENCODED ====================
[filepath,~,~] = fileparts([path,file]);
filepath = strcat(filepath,'/temp');
if ~exist(filepath, 'dir')
    mkdir(filepath);
end

key = [usehuffman noECC usehamming useR3];
FileSize = length(tBits);

if(usehuffman)
    [filepath,name,ext] = fileparts([path,file]);
    fid = fopen([filepath, '/temp/' , name, ext, '.beforeTransmit.zf'],'w');
    fwrite(fid,tBits,'ubit1');
    fclose('all');
    save([filepath, '/temp/', name, '_key'],'key','node','FileSize')
else
    [filepath,name,ext] = fileparts([path,file]);
    fid = fopen([filepath, '/temp/' , name, ext, '.beforeTransmit.zf'],'w');
    fwrite(fid,tBits,'ubit1');
    fclose('all');
    node = 0;
    save([filepath, '/temp/', name, '_key'],'key','node','FileSize')
end
[filepath,name,ext] = fileparts([path,file]);
fid = fopen([filepath, '/temp/' , name, ext, '.afterTransmit.zf'],'w');
fwrite(fid,rBits,'ubit1');
fclose('all');
disp("Message was successfully sent");