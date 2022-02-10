function [musout,success] = musoutreader(fileName)

success = 0;

musout  = struct('data',[],'columnNames','','PartID','');

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


success   = 1;