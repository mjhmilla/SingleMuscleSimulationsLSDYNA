function [musout,success] = musoutreader(modelName,fileName)

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
                'indexLceDot',0);



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

if(strcmp(modelName,'umat41')==1)
    musout.indexTime        = getColumnIndex('time',musout.columnNames);
    musout.indexExcitation  = getColumnIndex('stim_tot',musout.columnNames);
    musout.indexActivation  = getColumnIndex('q',musout.columnNames); %activation
    musout.indexFmt         = getColumnIndex('f_mtc',musout.columnNames);
    musout.indexFce         = getColumnIndex('f_ce',musout.columnNames);
    musout.indexFpee        = getColumnIndex('f_pee',musout.columnNames);
    musout.indexFsee        = getColumnIndex('f_see',musout.columnNames);
    musout.indexFsde        = getColumnIndex('f_sde',musout.columnNames);
    musout.indexLmt         = getColumnIndex('l_mtc',musout.columnNames);
    musout.indexLce         = getColumnIndex('l_ce',musout.columnNames);
    musout.indexLmtDot      = getColumnIndex('dot_l_mtc',musout.columnNames);
    musout.indexLceDot      = getColumnIndex('dot_l_ce',musout.columnNames);    
end

if(strcmp(modelName,'umat43')==1)
    musout.indexTime       = getColumnIndex('time',musout.columnNames);
    musout.indexExcitation = getColumnIndex('e',musout.columnNames);
    musout.indexActivation = getColumnIndex('a',musout.columnNames); %activation
    musout.indexFmt        = getColumnIndex('f_mtc',musout.columnNames);
end

success   = 1;