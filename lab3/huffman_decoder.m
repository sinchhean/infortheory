function dRawBytes = huffman_decoder(node,cRawBits)
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
end