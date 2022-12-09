function [musdebug,success] = readUmat43MusDebugData(fileName)

success = 0;

musdebug  = struct('data',[],'columnNames','','PartID','',...
                    'indexTime'         ,0,...
                    'indexPwrTi1K'      ,0,...  
                    'indexPwrTi2K'      ,0,...  
                    'indexPwrTi12'      ,0,...  
                    'indexPwrEcmK'      ,0,...  
                    'indexPwrEcmD'      ,0,...  
                    'indexPwrXeK'       ,0,...  
                    'indexPwrXeD'       ,0,...  
                    'indexPwrXeA'       ,0,...  
                    'indexPwrCpK'       ,0,...  
                    'indexPwrTK'        ,0,...  
                    'indexPwrTD'        ,0,...  
                    'indexPwrPP'        ,0,...  
                    'indexErrForce'     ,0,...  
                    'indexErrVel'       ,0);



fid = fopen(fileName);

%Get the part id
line=fgetl(fid);
tag = '(PartID):';
idx = strfind(line,tag)+length(tag);
musdebug.PartID = cell2mat(textscan(line(idx:end),'%f'));

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
musdebug.columnNames = textscan(line,headerFormat);

%Get the numeric data
%musdebug.data = cell2mat(textscan(fid,dataFormat,'collectoutput',1));
while ~feof(fid)
    cellData = textscan(fid, dataFormat, 'CollectOutput',true);
    matrixData = cell2mat(cellData);
    if isempty(matrixData)                                      
        break
    end
    musdebug.data = [musdebug.data; matrixData]; 
    fseek(fid, 0, 0);
end

fclose(fid);

musdebug.indexTime     =     getColumnIndex('time',      musdebug.columnNames);  
musdebug.indexTime     =     getColumnIndex('time',        musdebug.columnNames);
musdebug.indexPwrTi1K  =     getColumnIndex('pwrTi1K',     musdebug.columnNames);  
musdebug.indexPwrTi2K  =     getColumnIndex('pwrTi2K',     musdebug.columnNames);  
musdebug.indexPwrTi12  =     getColumnIndex('pwrTi12',     musdebug.columnNames);  
musdebug.indexPwrEcmK  =     getColumnIndex('pwrEcmK',     musdebug.columnNames);  
musdebug.indexPwrEcmD  =     getColumnIndex('pwrEcmD',     musdebug.columnNames);  
musdebug.indexPwrXeK   =     getColumnIndex('pwrXeK',      musdebug.columnNames);  
musdebug.indexPwrXeD   =     getColumnIndex('pwrXeD',      musdebug.columnNames);  
musdebug.indexPwrXeA   =     getColumnIndex('pwrXeA',      musdebug.columnNames);  
musdebug.indexPwrCpK   =     getColumnIndex('pwrCpK',      musdebug.columnNames);  
musdebug.indexPwrTK    =     getColumnIndex('pwrTK',       musdebug.columnNames);  
musdebug.indexPwrTD    =     getColumnIndex('pwrTD',       musdebug.columnNames);  
musdebug.indexPwrPP    =     getColumnIndex('pwrPP',       musdebug.columnNames);  
musdebug.indexErrForce =     getColumnIndex('errForce',    musdebug.columnNames);  
musdebug.indexErrVel   =     getColumnIndex('errVel',      musdebug.columnNames); 

success   = 1;