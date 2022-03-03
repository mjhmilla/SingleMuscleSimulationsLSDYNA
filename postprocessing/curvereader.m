function [curve,success] = curvereader(fileName)

success = 0;

curve  = struct('name', fileName,...
                'data',[],...
                'columnNames','',...
                'PartID','',...
                'indexTime',0,...
                'indexArg',0,...
                'indexValue',0,...
                'index1stDer',0,...
                'index2ndDer',0);



fid = fopen(fileName);

%Get the part id
line=fgetl(fid);
tag = '(PartID):';
idx = strfind(line,tag)+length(tag);
curve.PartID = cell2mat(textscan(line(idx:end),'%f'));

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
curve.columnNames = textscan(line,headerFormat);

%Get the numeric data
%curve.data = cell2mat(textscan(fid,dataFormat,'collectoutput',1));
while ~feof(fid)
    cellData = textscan(fid, dataFormat, 'CollectOutput',true);
    matrixData = cell2mat(cellData);
    if isempty(matrixData)                                      
        break
    end
    curve.data = [curve.data; matrixData]; 
    fseek(fid, 0, 0);
end

fclose(fid);

curve.indexTime   = getColumnIndex('time',curve.columnNames);
curve.indexArg    = getColumnIndex('arg',curve.columnNames);
curve.indexValue  = getColumnIndex('val',curve.columnNames); %activation
curve.index1stDer = getColumnIndex('der1',curve.columnNames);
curve.index2ndDer = getColumnIndex('der2',curve.columnNames);

success   = 1;