clear variables
clc
%=============== READ TEXT FILE =======================
disp('Select the .afterTransmit.chhean as received file')
[file,path] = uigetfile('*.afterTransmit.chhean');
fid = fopen([path,file]);
rawBits = fread(fid,'*ubit1')';
fclose('all');
disp('Select the .chhean.key as key file')
[keyfile,path] = uigetfile('*.chhean.key');
fid = fopen([path,keyfile]);
key = fread(fid,'*ubit1')';
fclose('all');