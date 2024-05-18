function params = getAllParameterFieldsAndValues(fileName)

val=NaN;

fid=fopen(fileName);

line            = fgetl(fid);
lineFound       = 0;
parametersStarted = 0;
parametersEnded   = 0;
params=[];

while ~feof(fid) && parametersEnded==0
    
    if(contains(line,'*PARAMETER')==1 && parametersStarted==0)
        parametersStarted=1;
        line=fgetl(fid);
    elseif(strcmp(line(1,1),'*') && parametersStarted==1)
        parametersEnded=1;
    elseif(parametersStarted==1)
        if(contains(line(1,1),'#') == 0)
            fieldName = strtrim(line(1,2:10));
            fieldValue = str2double(strtrim(line(1,11:end)));
            params.(fieldName)=fieldValue;
        end
    end
    if(parametersEnded==0)
        line=fgetl(fid);
    end
end


fclose(fid);