%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%%
function [musout,success] = readUmat43MusoutData(fileName)

success = 0;

musout  = struct('data',[],'columnNames','','PartID','',...
                    'indexTime'            ,0,...
                    'indexLp'           ,0,...  
                    'indexVp'           ,0,...  
                    'indexExc'          ,0,...  
                    'indexAct'          ,0,...  
                    'indexLceATN'       ,0,...  
                    'indexL1HN'         ,0,...  
                    'indexLsHN'         ,0,...  
                    'indexVsHNN'        ,0,...  
                    'indexActDot'       ,0,...  
                    'indexLceATNDot'    ,0,...  
                    'indexL1HNDot'      ,0,...  
                    'indexLsHNDot'      ,0,...  
                    'indexVsHNNDot'     ,0,...  
                    'indexLceN'         ,0,...  
                    'indexVceNN'        ,0,...  
                    'indexFceN'         ,0,...  
                    'indexAlpha'        ,0,...  
                    'indexAlphaDot'     ,0,...  
                    'indexFceATN'       ,0,...  
                    'indexLtN'          ,0,...  
                    'indexVtN'          ,0,...  
                    'indexFtN'          ,0,...  
                    'indexLaN'          ,0,...  
                    'indexFalN'         ,0,...  
                    'indexVaNN'         ,0,...  
                    'indexFvN'          ,0,...  
                    'indexLceHN'        ,0,...  
                    'indexFecmHN'       ,0,...  
                    'indexF1HN'         ,0,...  
                    'indexL2HN'         ,0,...  
                    'indexF2HN'         ,0,...  
                    'indexLxHN'         ,0,...  
                    'indexVxHN'         ,0,...  
                    'indexFxHN'         ,0,...  
                    'indexFtfcnN'       ,0,...  
                    'indexKtfcnN'      ,0,...  
                    'indexDvsHNHill'    ,0,...  
                    'indexDvsHNDamping' ,0,... 
                    'indexDvsHNTracking',0,...
                    'indexDTVmWDt',0,...
                    'indexLceNRef',0);



fid = fopen(fileName);

%Get the part id
line=fgetl(fid);
tag = '(PartID):';
idx = strfind(line,tag)+length(tag);
musout.PartID = cell2mat(textscan(line(idx:end),'%f'));

%Count the number of column headers
line=fgetl(fid);
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

musout.indexTime          = getColumnIndex('time',       musout.columnNames);  

musout.indexLp            = getColumnIndex('lp',         musout.columnNames);  
musout.indexVp            = getColumnIndex('vp',         musout.columnNames);  
musout.indexExc           = getColumnIndex('e',          musout.columnNames);  

musout.indexAct           = getColumnIndex('a',          musout.columnNames);  
musout.indexLceATN        = getColumnIndex('lceATN',     musout.columnNames);  
musout.indexL1HN          = getColumnIndex('l1HN',       musout.columnNames);  
musout.indexLsHN          = getColumnIndex('lsHN',       musout.columnNames);  
musout.indexVsHNN         = getColumnIndex('vsHNN',      musout.columnNames);  

musout.indexActDot        = getColumnIndex('aDot',       musout.columnNames);  
musout.indexLceATNDot     = getColumnIndex('vceATN',     musout.columnNames);  
musout.indexL1HNDot       = getColumnIndex('v1HN',       musout.columnNames);  
musout.indexLsHNDot       = getColumnIndex('vsHN',       musout.columnNames);  
musout.indexVsHNNDot      = getColumnIndex('vsHNNDot',   musout.columnNames);  

musout.indexLceN          = getColumnIndex('lceN',       musout.columnNames);  
musout.indexVceNN         = getColumnIndex('vceNN',      musout.columnNames);  
musout.indexFceN          = getColumnIndex('fceN',       musout.columnNames);  
musout.indexAlpha         = getColumnIndex('alpha',      musout.columnNames);  
musout.indexAlphaDot      = getColumnIndex('dalpha',     musout.columnNames);  

musout.indexFceATN        = getColumnIndex('fceATN',     musout.columnNames);  
musout.indexLtN           = getColumnIndex('ltN',        musout.columnNames);  
musout.indexVtN           = getColumnIndex('vtN',        musout.columnNames);  
musout.indexFtN           = getColumnIndex('ftN',        musout.columnNames);  
musout.indexLaN           = getColumnIndex('laN',        musout.columnNames);  
musout.indexFalN          = getColumnIndex('falN',       musout.columnNames);  
musout.indexVaNN          = getColumnIndex('vaNN',       musout.columnNames);  
musout.indexFvN           = getColumnIndex('fvN',        musout.columnNames);
  
musout.indexLceHN         = getColumnIndex('lceHN',      musout.columnNames);  
musout.indexFecmHN        = getColumnIndex('fecmHN',     musout.columnNames);  
musout.indexF1HN          = getColumnIndex('f1HN',       musout.columnNames);  
musout.indexL2HN          = getColumnIndex('l2HN',       musout.columnNames);  
musout.indexF2HN          = getColumnIndex('f2HN',       musout.columnNames);  
musout.indexLxHN          = getColumnIndex('lxHN',       musout.columnNames);  
musout.indexVxHN          = getColumnIndex('vxHN',       musout.columnNames);  
musout.indexFxHN          = getColumnIndex('fxHN',       musout.columnNames);  
musout.indexFtfcnN        = getColumnIndex('ftFcnN',     musout.columnNames);  
musout.indexFtBetaN       = getColumnIndex('ftBetaN',    musout.columnNames);  
musout.indexDvsHNHill     = getColumnIndex('dvsHNHill',  musout.columnNames);  
musout.indexDvsHNDamping  = getColumnIndex('dvsHNDamp',  musout.columnNames); 
musout.indexDvsHNTracking = getColumnIndex('dvsHNTrak',  musout.columnNames);

musout.indexDTVmWDt = getColumnIndex('D_TpVmW_Dt',musout.columnNames);

musout.indexLceNRef = getColumnIndex('ctrlLceN0',musout.columnNames);

success   = 1;