clear variables
clc
%=============== READ TEXT FILE =======================
disp('Select the .afterTransmit.zf as received file')
[file1,path1] = uigetfile('*.afterTransmit.zf');
fid = fopen([path1,file1]);
after_rawBits = fread(fid,'*ubit1')';
fclose('all');
disp('Select the .beforeTransmit.zf to check for error')
[file2,path2] = uigetfile('*.beforeTransmit.zf');
fid = fopen([path2,file2]);
before_rawBits = fread(fid,'*ubit1')';
fclose('all');
disp('Select the .zf.key as key file')
[matfile,matpath] = uigetfile('*.mat');
load([matpath,matfile],'key','node','FileSize')
k = 0;
after_rawBits = after_rawBits(1:FileSize);
before_rawBits = before_rawBits(1:FileSize);
usehuffman = key(1);
noECC = key(2);
usehamming = key(3);
useR3 = key(4);

if noECC
    shBits = after_rawBits;
elseif usehamming 
    shBits = hamming_decoder(after_rawBits);
elseif useR3
    shBits = r3_decoder(after_rawBits);
end

if usehuffman
    dRawBytes = huffman_decoder(node,shBits);
    %======================= STORE THE DECOMPRESSED FILE ======================
    [filepath,name,ext] = fileparts([path,file]);
    dot = find(name == '.');
    fid = fopen([filepath, '/' , name(1:dot-1), '_received', name(dot:end)],'w');
    fwrite(fid,dRawBytes,'ubit8');
    fclose('all');
else
    [filepath,name,ext] = fileparts([path1,file1]);
    dot = find(name == '.');
    fid = fopen([filepath, '/' , name(1:dot-1), '_received', name(dot:end)],'w');
    fwrite(fid,shBits,'ubit1');
    fclose('all');
end

