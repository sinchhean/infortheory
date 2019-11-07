%=============== HUFFMAN COMPRESSION ====================================
clear variables
clc

disp('Select a file')
[file,path] = uigetfile('*.*');
fid = fopen([path,file]);
rawBytes = fread(fid,'*ubit8')';
rawBytes = int16(rawBytes);
fclose('all');

symbol = uint8(0:255);
count = zeros(1,256);
BITS_PER_BYTE = 8;

%=================== COUNTING THE SYMBOLS =================================
% Counting the number of occurrences for each symbol
% The symbols should be stored in an array named symbol
% while their count (frequency) should be stored in an array named count
for i=1:length(rawBytes)
    for j=1:length(symbol)
        if rawBytes(i) == symbol(j)
            count(j) = count(j)+1;
            break;
        end       
    end
end

% truncate zero-count symbols
symbol = symbol(count > 0);     
count = count(count > 0);
N_leaves = length(symbol);
N_nodes = N_leaves;

%========================= BUILD THE TREE =================================
% Initialize an array containing N instances of the node structure
% (in other words, initialize N leaf nodes)
node(1:N_nodes) = struct('ID',[],'sym',[],'weight',[],'codeword',[],'active',false,'child0',[],'child1',[]);     

for i = 1:N_nodes
    node(i).ID = i;
    node(i).sym = symbol(i);
    node(i).weight = count(i);
    node(i).active = true;
end

while true
    N_nodes = N_nodes + 1;
    % Add a new node and assign an ID for it
    node(N_nodes).ID = N_nodes;
    node(N_nodes).active = false;
    
    % This new node will be the parent node of the two least weighted node
    % so we need to find the IDs and the weights of those two nodes
    % To do so, get the weights and IDs of active nodes i.e., nodes whose
    % 'active' field is true, into two arrays, 
    % namely activeIDs and activeWeights
    
    
    % Sort the activeWeights array descending order and 
    % rearrange the activeIDs array accordingly i.e., in the rearranged 
    % activeIDs array, the ID of the least weighted node is also at the 
    % rightmost position (see MATLAB sort function)
    
    
    % Get the weights and IDs of the two least weighted nodes from
    % the (sorted) activeWeights and (rearranged) activeIDs array
    % Update the new parent node as follows:
    % Set child0 and child1 of this node to the IDs of the two least
    % weighted nodes obtained from previous step
    
    
    % Set weight of this node to sum of the weights of two children
    
    % Deactivate the two children nodes
    
    
    % Activate the current node
    
    % Check if there is only one active node among all nodes and
    % exit the while loop if that is the case (since we have reached
    % the root node)
    
    
end

%==================== CONVERT TREE TO CODE ================================
% Add the ID of the root node (which is also the last node) to the
% list of nodes to traverse i.e., we are going from the top down
nodeToTraverse = N_nodes;
while ~isempty(nodeToTraverse)
    % Go to the first node in the list
    currentNode = nodeToTraverse(1);
    
    % The main purpose of this step is to assign codewords to the nodes.
    % Each time we reach a certain node, we can assign codewords to
    % both of its children based on its codeword. Thus, we only need to
    % process nodes that have children i.e., non-leaf nodes, to complete
    % the task of assigning codewords
    if currentNode > N_leaves
        % Assign appropriate codewords to its two children

        
        % Update the list of node to traverse by removing this node
        % and adding two children to the list
        
    else
        % If this node is a leaf node, then do nothing except removing
        % it from the list of node to traverse
        
    end    
end

%===================== COMPRESS THE FILE ==================================
for i = 1:length(rawBytes)
    % For each symbol in the file, find its corresponding position in symbol
    % array (see COUNTING THE SYMBOL). That position (index) is also the order
    % of the corresponding leaf node in the node array. Get the codeword  
    % associated with that leaf node and write it to the output array.
    % The output array should be named cRawBits
end

%=========== SAVE THE COMPRESSED FILE AND THE HUFFMAN TREE ================
[filepath,name,ext] = fileparts([path,file]);
fid = fopen([filepath, '\' , name, ext, '.fu'],'w');
fwrite(fid,cRawBits,'ubit1');
fclose('all');
compressedFileSize = length(cRawBits);
save([filepath, '\', name, '_Tree'],'node','compressedFileSize')

%==================== TEST IF COMPRESSED CORRECTLY ========================
s = 0;
for i = 1:N_nodes
s = s + node(i).weight*length(node(i).codeword);
end
s - length(cRawBits)
if s ~= 0
    error('Compressed incorrectly')
end