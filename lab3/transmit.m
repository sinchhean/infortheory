clear variables
clc
%=============== READ TEXT FILE =======================
disp('Select the .beforeTransmit.chhean file as file to transmit')
[file,path] = uigetfile('*.beforeTransmit.chhean');
fid = fopen([path,file]);
sBits = fread(fid,'*ubit1')';
fclose('all');
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
        fBits = uint8(rand(1,length(sBits)) <= f);
    % and get a (corrupted) array rBits (received Bits)
        rBits = bitxor(sBits,fBits);
%=============OUTPUT THE TRANSMITED FILE============================
last2dot_pos = find(file == '.', 2, 'last');  
name = file(1 : last2dot_pos(1) - 1);
[filepath,~,~] = fileparts([path,file]);
fid = fopen([filepath, '/' , name, '.afterTransmit.chhean'],'w');
fwrite(fid,rBits,'ubit1');
fclose('all');
disp("Message was transmitted");