%======================= LOAD THE COMPRESSED FILE IN ======================
clear variables
clc
% Read the file in, bit by bit
disp('Select a compressed .fu file')
[file,path] = uigetfile('*.fu');

fid = fopen([path,file]);
cRawBits = fread(fid,'*ubit1')';

% Read the node array i.e., the Huffman tree, in
disp('Select a Huffman tree .mat file')
[matfile,matpath] = uigetfile('*.mat');
load([matpath,matfile],'node','compressedFileSize')

% Remove data padded by Operating System
cRawBits = cRawBits(1:compressedFileSize);
k = 0;
%======================== DECOMPRESS THE FILE =============================
% Traverse the tree i.e., the node array, from the root node (the last node
% in the array) according to each read bits until reaching a leaf node
% i.e., a node with no children. At that point, extract the symbol field
% of the leaf node to get the original data and write it to the output
% array. Repeat until we have processed the whole input compressed file
% Note: The output array should be named dRawBytes
%dRawBytes = [];
dRawBytes = zeros(1,int16(length(cRawBits)/8));
pointer = 1;

currentnode = length(node);
i = 1;
while i <= length(cRawBits)
    while isempty(node(currentnode).sym)
        if cRawBits(i) == 0
            currentnode = node(currentnode).child0;
        else
            currentnode = node(currentnode).child1;
        end  
        i = i + 1;
    end
    dRawBytes(pointer) = node(currentnode).sym;
    pointer = pointer + 1;
    currentnode = length(node);
end
dRawBytes = dRawBytes(1: pointer-1);

%======================= STORE THE DECOMPRESSED FILE ======================
[filepath,name,ext] = fileparts([path,file]);
dot = find(name == '.');
fid = fopen([filepath, '/' , name(1:dot-1), '_decompressed', name(dot:end)],'w');
fwrite(fid,dRawBytes,'ubit8');
fclose('all');