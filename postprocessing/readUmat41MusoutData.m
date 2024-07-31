%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%%
function [musout,success] = readUmat41MusoutData(fileName)

success = 0;

musout  = struct('data',[],'columnNames','','PartID','',...
                'indexTime',0,...
                'indexExcitation',0,...
                'indexActivation',0,...
                'indexFmt',0,...
                'indexFce',0,...
                'indexFpee',0,...
                'indexFsee',0,...
                'indexFsde',0,...
                'indexLmt',0,...
                'indexLce',0,...
                'indexLmtDot',0,...
                'indexLceDot',0,...
                'indexLceDelay',0);

%         time     stim_tot            q''
%     1       ''        f_mtc         f_ce        f_pee        f_see''
%     2       ''        f_sde        l_mtc         l_ce''
%     3       ''    dot_l_mtc     dot_l_ce     del_l_ce del_dot_l_ce''
%     4       ''     l_ce_ref         e_ce         stim    stim_flag''

fid = fopen(fileName);

%Get the part id
line=fgetl(fid);
tag = '(PartID):';
idx = strfind(line,tag)+length(tag);
musout.PartID = cell2mat(textscan(line(idx:end),'%f'));

%Keep reading the file until you get to the column header
line=fgetl(fid);
while(~contains(line,' time '))
    line=fgetl(fid);
end

numberOfColumns=0;
headerFormat = '';
dataFormat = '';
for i=2:1:length(line)
  if(strcmp(line(i-1),' ')==1 && strcmp(line(i),' ')==0)
    numberOfColumns = numberOfColumns+1;
    headerFormat    = [headerFormat,'%s'];
    dataFormat      = [dataFormat,'%f'];
  end
end

%Get the header data
musout.columnNames = textscan(line,headerFormat);

%Get the numeric data
%musout.data = cell2mat(textscan(fid,dataFormat,'collectoutput',1));
while ~feof(fid)
    cellData = textscan(fid, dataFormat, 'CollectOutput',true);
    matrixData = cell2mat(cellData);
    if isempty(matrixData)                                      
        break
    end
    musout.data = [musout.data; matrixData]; 
    fseek(fid, 0, 0);
end

fclose(fid);


    musout.indexTime        = getColumnIndex('time',musout.columnNames);
    musout.indexExcitation  = getColumnIndex('stim_tot',musout.columnNames);
    musout.indexActivation  = getColumnIndex('q',musout.columnNames); %activation
    musout.indexFmt         = getColumnIndex('f_mtu',musout.columnNames);
    musout.indexFce         = getColumnIndex('f_ce',musout.columnNames);
    musout.indexFpee        = getColumnIndex('f_pee',musout.columnNames);
    musout.indexFsee        = getColumnIndex('f_see',musout.columnNames);
    musout.indexFsde        = getColumnIndex('f_sde',musout.columnNames);
    musout.indexLmt         = getColumnIndex('l_mtu',musout.columnNames);
    musout.indexLce         = getColumnIndex('l_ce',musout.columnNames);
    musout.indexLmtDot      = getColumnIndex('dot_l_mtu',musout.columnNames);
    musout.indexLceDot      = getColumnIndex('dot_l_ce',musout.columnNames);    
    musout.indexLceDelay    = getColumnIndex('del_l_ce',musout.columnNames);

success   = 1;